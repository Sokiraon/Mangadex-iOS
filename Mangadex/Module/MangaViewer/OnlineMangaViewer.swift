//
//  OnlineMangaViewer.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit
import ProgressHUD
import Kingfisher
import SnapKit
import Darwin
import PromiseKit
import MJRefresh
import SafariServices

class OnlineMangaViewer: MangaViewer {
    
    private func bottomButtonBuilder(
        image: UIImage?, titleKey: String, action: UIAction
    ) -> UIButton {
        var conf = UIButton.Configuration.plain()
        conf.buttonSize = .small
        conf.baseForegroundColor = .white
        conf.image = image
        conf.imagePadding = 8
        conf.imagePlacement = .top
        var titleContainer = AttributeContainer()
        titleContainer.font = .systemFont(ofSize: 14)
        conf.attributedTitle = AttributedString(titleKey.localized(), attributes: titleContainer)
        let button = UIButton(configuration: conf, primaryAction: action)
        return button
    }
    
    private lazy var btnSettings = bottomButtonBuilder(
        image: .init(systemName: "gearshape.fill"),
        titleKey: "kMangaViewerSettings",
        action: UIAction { _ in }
    )
    private lazy var btnInfo = bottomButtonBuilder(
        image: .init(systemName: "info.circle.fill"),
        titleKey: "kMangaViewerInfo",
        action: UIAction { _ in }
    )
    private lazy var btnComment = bottomButtonBuilder(
        image: .init(systemName: "bubble.left.and.bubble.right.fill"),
        titleKey: "kMangaViewerComment",
        action: UIAction { _ in self.openForumSafe() }
    )
    private lazy var btnDownload = bottomButtonBuilder(
        image: .init(systemName: "arrow.down.circle.fill"),
        titleKey: "kMangaViewerDownload",
        action: UIAction { _ in self.downloadChapter() }
    )
    private lazy var btnChapters = bottomButtonBuilder(
        image: .init(systemName: "list.bullet.circle.fill"),
        titleKey: "kMangaViewerChapters",
        action: UIAction { _ in }
    )
    
    private lazy var vBottomActions = UIStackView(
        arrangedSubviews: [btnComment, btnDownload, btnChapters]
    )
    
    // MARK: - Lifecycle methods
    
    convenience init(mangaModel: MangaItemDataModel, chapterId: String) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterId = chapterId
    }
    
    convenience init(
        mangaModel: MangaItemDataModel,
        chapterId: String,
        aggregatedModel: MDMangaAggregatedModel
    ) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterId = chapterId
        self.aggregatedModel = aggregatedModel
    }
    
    override func setupUI() {
        super.setupUI()
        
        vBottomControl.addSubview(vSlider)
        vSlider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8)
        }
        
        vBottomControl.addSubview(btnPrev)
        btnPrev.snp.makeConstraints { make in
            make.centerY.equalTo(vSlider)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(vSlider.snp.left).offset(-16)
        }
        
        vBottomControl.addSubview(btnNext)
        btnNext.snp.makeConstraints { make in
            make.centerY.equalTo(vSlider)
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(vSlider.snp.right).offset(16)
        }
        
        vBottomControl.addSubview(vBottomActions)
        vBottomActions.snp.makeConstraints { make in
            make.top.equalTo(btnPrev.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(MDLayout.adjustedSafeInsetBottom)
        }
    }
    
    override func didSetupUI() {
        fetchData(withAggregate: aggregatedModel == nil)
    }
    
    // MARK: - Model
    
    private var mangaModel: MangaItemDataModel!
    
    private var chapterId: String!
    private var chapterModel: MDMangaChapterModel!
    private var statistics: MDChapterStatistics!
    
    private var aggregatedModel: MDMangaAggregatedModel!
    private var chaptersInfo: [MDMangaAggregatedChapter] {
        aggregatedModel.chapters
    }
    
    private lazy var currentIndex: Int = {
        chaptersInfo.firstIndex { chapterInfo in
            chapterInfo.id == chapterId
        }!
    }()
    
    private func fetchData(withAggregate: Bool) {
        ProgressHUD.show()
        firstly {
            when(fulfilled: MDRequests.Chapter.get(id: chapterId),
                 MDRequests.Chapter.getStatistics(id: chapterId)
            )
        }.then { (chapterModel: MDMangaChapterModel, statistics: MDChapterStatistics) in
            self.statistics = statistics
            self.chapterModel = chapterModel
            self.appBar.title = chapterModel.attributes.chapterName
            self.updateReadingStatus()
            if withAggregate {
                return when(fulfilled: MDRequests.Chapter.getPageData(chapterId: chapterModel.id),
                            MDRequests.Manga.getVolumesAndChapters(
                               mangaId: chapterModel.mangaId ?? "",
                               groupId: chapterModel.scanlationGroup?.id ?? "",
                               language: chapterModel.attributes.translatedLanguage
                            )
                       )
            } else {
                return when(fulfilled: MDRequests.Chapter.getPageData(chapterId: chapterModel.id),
                            MDRequests.Placeholder(self.aggregatedModel)
                )
            }
        }.done { pagesModel, aggregatedModel in
            let hash = pagesModel.chapter.chapterHash
            self.pageURLs = pagesModel.chapter.data.map { fileName in
                URL(string: "\(pagesModel.baseUrl!)/data/\(hash!)/\(fileName)")!
            }
            // Set slider range based on page count
            self.vSlider.maximumValue = Float(self.pageURLs.count - 1)
            self.aggregatedModel = aggregatedModel

            if self.currentIndex == 0 {
                self.btnPrev.isEnabled = false
                self.btnPrev.setTitleColor(.darkGray808080, for: .normal)
            }
            if self.currentIndex == self.chaptersInfo.count - 1 {
                self.btnNext.isEnabled = false
                self.btnNext.setTitleColor(.darkGray808080, for: .normal)
            }

            DispatchQueue.main.async {
                self.vPages.reloadData()
                self.toggleControlArea()
                ProgressHUD.dismiss()
            }
        }.catch { error in
            DispatchQueue.main.async {
                ProgressHUD.showError()
            }
        }
    }
    
    override var previousViewController: MangaViewer? {
        guard let chapterInfo = self.chaptersInfo.get(self.currentIndex - 1) else {
            return nil
        }
        return OnlineMangaViewer(
            mangaModel: self.mangaModel,
            chapterId: chapterInfo.id,
            aggregatedModel: self.aggregatedModel
        )
    }
    
    override var nextViewController: MangaViewer? {
        guard let chapterInfo = self.chaptersInfo.get(self.currentIndex + 1) else {
            return nil
        }
        return OnlineMangaViewer(
            mangaModel: self.mangaModel,
            chapterId: chapterInfo.id,
            aggregatedModel: self.aggregatedModel
        )
    }
    
    // MARK: - Actions
    
    /// Mark the current chapter as **read** to the Mangadex server,
    /// and save the status in MDMangaProgressManager so that users can return to their last read chapter.
    private func updateReadingStatus() {
        if let mangaId = chapterModel?.mangaId {
            _ = MDRequests.Chapter.markAsRead(mangaId: mangaId, chapterId: chapterId)
            MDMangaProgressManager.saveProgress(forMangaId: mangaId, chapterId: chapterId)
        }
    }
    
    @objc private func downloadChapter() {
        Task {
            await DownloadsManager.default.downloadChapter(
                mangaModel: mangaModel, chapterModel: chapterModel, pageURLs: pageURLs
            )
        }
        ProgressHUD.showSuccess("kInfoMessageAddedDownload".localized())
    }
    
    /// A method to open forum thread safely.
    /// It will alert the user to create the corresponding thread if it does not exist.
    @objc private func openForumSafe() {
        if self.statistics.comments != nil {
            openForum()
        } else {
            let alert = UIAlertController(
                title: "kInfo".localized(), message: "kAlertMessageNoThread".localized(), preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "kCancel".localized(), style: .cancel))
            alert.addAction(UIAlertAction(title: "kOk".localized(), style: .default, handler: { action in
                _ = MDRequests.Chapter.createForumThread(chapterId: self.chapterId)
                    .done { statistics in
                        self.statistics = statistics
                        self.openForum()
                    }
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func openForum() {
        if let threadId = self.statistics.comments?.threadId {
            if let url = URL(string: "https://forums.mangadex.org/threads/\(threadId)") {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true)
            }
        }
    }
}
