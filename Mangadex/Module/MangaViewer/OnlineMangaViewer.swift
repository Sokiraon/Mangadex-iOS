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
        action: UIAction { _ in self.showHideChapterList() }
    )
    
    private lazy var vBottomActions = UIStackView(
        arrangedSubviews: [btnComment, btnDownload, btnChapters]
    )
    
    // MARK: - Lifecycle methods
    
    convenience init(mangaModel: MangaModel, chapterId: String) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterId = chapterId
    }
    
    convenience init(
        mangaModel: MangaModel,
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
        
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = true
        listConfig.separatorConfiguration.color = .darkerGray565656
        listConfig.headerMode = .supplementary
        listConfig.headerTopPadding = 0
        listConfig.backgroundColor = .fromHex("1c1c1e")
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        chapterListView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        chapterListView.delegate = self
        
        view.addSubview(chapterListView)
        view.layoutIfNeeded()
        chapterListView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(appBar.frame.height)
            make.bottom.equalToSuperview().inset(vBottomControl.frame.height)
            make.left.equalTo(view.snp.right)
            make.width.equalTo(240)
        }
    }
    
    override func didSetupUI() {
        fetchData(withAggregate: aggregatedModel == nil)
    }
    
    // MARK: - Model
    
    private var mangaModel: MangaModel!
    
    private var chapterId: String!
    private var chapterModel: ChapterModel!
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
            when(fulfilled: Requests.Chapter.get(id: chapterId),
                 Requests.Chapter.getStatistics(id: chapterId)
            )
        }.then { (chapterModel: ChapterModel, statistics: MDChapterStatistics) in
            self.statistics = statistics
            self.chapterModel = chapterModel
            self.appBar.title = chapterModel.attributes.chapterName
            self.updateReadingStatus()
            if withAggregate {
                return when(fulfilled: Requests.Chapter.getPageData(chapterId: chapterModel.id),
                            Requests.Manga.getVolumesAndChapters(
                               mangaId: chapterModel.mangaId!,
                               groupId: chapterModel.scanlationGroup?.id,
                               language: chapterModel.attributes.translatedLanguage
                            )
                       )
            } else {
                return when(fulfilled: Requests.Chapter.getPageData(chapterId: chapterModel.id),
                            Requests.Placeholder(self.aggregatedModel)
                )
            }
        }.done { pagesModel, aggregatedModel in
            self.pageURLs = pagesModel.pageURLs
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
            
            self.setupChapterList()

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
    
    private func setupChapterList() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, MDMangaAggregatedVolumeChapter>
        { cell, indexPath, itemIdentifier in
            var content = cell.defaultContentConfiguration()
            content.text = "mangaViewer.chapterList.chapterName"
                .localizedFormat(itemIdentifier.chapter)
            content.textProperties.color = .white
            cell.contentConfiguration = content
            cell.backgroundConfiguration = .clear()
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader)
        { supplementaryView, elementKind, indexPath in
            var content = UIListContentConfiguration.sidebarHeader()
            if let volumeNumber = Int(self.aggregatedModel.volumeNames[indexPath.section]) {
                content.text = "mangaViewer.chapterList.volumeName".localizedFormat(volumeNumber)
            } else {
                content.text = "mangaViewer.chapterList.noVolume".localized()
            }
            content.textProperties.color = .white
            supplementaryView.contentConfiguration = content
            var background = UIBackgroundConfiguration.listSidebarHeader()
            background.cornerRadius = 0
            background.backgroundColor = .fromHex("3d3d3d")
            supplementaryView.backgroundConfiguration = background
        }
        
        chapterListDataSource = UICollectionViewDiffableDataSource<String, MDMangaAggregatedVolumeChapter>(
            collectionView: chapterListView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        chapterListDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<String, MDMangaAggregatedVolumeChapter>()
        snapshot.appendSections(aggregatedModel.volumeNames)
        for volume in aggregatedModel.volumeNames {
            snapshot.appendItems(aggregatedModel.volumes[volume]!.sortedChapters,
                                 toSection: volume)
        }
        chapterListDataSource.apply(snapshot)
    }
    
    // MARK: - Actions
    
    /// Mark the current chapter as **read** to the Mangadex server,
    /// and save the status in MDMangaProgressManager so that users can return to their last read chapter.
    private func updateReadingStatus() {
        if let mangaId = chapterModel?.mangaId {
            _ = Requests.Chapter.markAsRead(mangaId: mangaId, chapterId: chapterId)
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
                _ = Requests.Chapter.createForumThread(chapterId: self.chapterId)
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

extension OnlineMangaViewer {
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView == chapterListView {
            let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
            cell.backgroundColor = .darkerGray565656
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView == chapterListView {
            let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
            UIView.animate(withDuration: 0.2) {
                cell.backgroundColor = .clear
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == chapterListView {
            let volumeName = aggregatedModel.volumeNames[indexPath.section]
            let chapter = aggregatedModel.volumes[volumeName]!.sortedChapters[indexPath.item]
            let vc = OnlineMangaViewer(
                mangaModel: mangaModel, chapterId: chapter.id, aggregatedModel: aggregatedModel)
            navigationController?.replaceTopViewController(with: vc, animated: true)
        }
    }
}
