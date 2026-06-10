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
import MJRefresh
import SafariServices

class OnlineMangaViewer: MangaViewer {

    private let chapterListMargin: CGFloat = 12
    private let chapterListWidth: CGFloat = 160

    override var chapterListTrailingMargin: CGFloat {
        8
    }
    
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
    
//    private lazy var btnSettings = bottomButtonBuilder(
//        image: .init(systemName: "gearshape.fill"),
//        titleKey: "kMangaViewerSettings",
//        action: UIAction { _ in }
//    )
//    private lazy var btnInfo = bottomButtonBuilder(
//        image: .init(systemName: "info.circle.fill"),
//        titleKey: "kMangaViewerInfo",
//        action: UIAction { _ in }
//    )
    private lazy var btnComment = bottomButtonBuilder(
        image: .init(systemName: "bubble.left.and.bubble.right.fill"),
        titleKey: "kMangaViewerComment",
        action: UIAction { [unowned self] _ in self.openForumSafe() }
    )
    private lazy var btnDownload = bottomButtonBuilder(
        image: .init(systemName: "arrow.down.circle.fill"),
        titleKey: "kMangaViewerDownload",
        action: UIAction { [unowned self] _ in self.downloadChapter() }
    )
    private lazy var btnChapters = bottomButtonBuilder(
        image: .init(systemName: "list.bullet.circle.fill"),
        titleKey: "kMangaViewerChapters",
        action: UIAction { [unowned self] _ in self.showHideChapterList() }
    )
    
    private lazy var vBottomActions = UIStackView(
        arrangedSubviews: [btnComment, btnDownload, btnChapters]
    )
    
    // MARK: - Lifecycle methods
    
    convenience init(mangaModel: MangaModel, chapterId: String) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterId = chapterId
        self.readingContext = self
    }
    
    convenience init(
        mangaModel: MangaModel,
        chapterId: String,
        aggregatedModel: MangaAggregatedModel
    ) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterId = chapterId
        self.aggregatedModel = aggregatedModel
        self.readingContext = self
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
        listConfig.separatorConfiguration.color = UIColor.white.withAlphaComponent(0.12)
        listConfig.headerMode = .supplementary
        listConfig.headerTopPadding = 0
        listConfig.backgroundColor = .clear
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        chapterListView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        chapterListView.delegate = self
        chapterListView.backgroundColor = .clear

        let chapterListContainerView = makeChapterListContainerView()
        self.chapterListContainerView = chapterListContainerView
        view.addSubview(chapterListContainerView)
        chapterListContainerView.contentView.addSubview(chapterListView)
        view.layoutIfNeeded()
        chapterListContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(appBar.frame.height + chapterListMargin)
            make.bottom.equalToSuperview().inset(vBottomControl.frame.height + chapterListMargin)
            make.left.equalTo(view.snp.right)
            make.width.equalTo(chapterListWidth)
        }
        chapterListView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }

    private func makeChapterListContainerView() -> UIVisualEffectView {
        let effectView: UIVisualEffectView
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .clear)
            effect.isInteractive = true
            effect.tintColor = UIColor.black.withAlphaComponent(0.58)
            effectView = UIVisualEffectView(effect: effect)
        } else {
            effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        }
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        dimmingView.isUserInteractionEnabled = false
        effectView.contentView.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        effectView.clipsToBounds = true
        effectView.layer.cornerRadius = 24
        effectView.layer.cornerCurve = .continuous
        return effectView
    }
    
    override func didSetupUI() {
        Task {
            await fetchData(withAggregate: aggregatedModel == nil)
            restoreReadingProgressIfNeeded()
        }
    }
    
    // MARK: - Model
    
    private var mangaModel: MangaModel!
    
    private var chapterId: String!
    private var chapterModel: ChapterModel!
    private var statistics: ChapterStatisticsModel!
    
    private var aggregatedModel: MangaAggregatedModel! {
        didSet {
            chaptersInfo = aggregatedModel.getOrderedChapters()
        }
    }
    private var chaptersInfo = [MangaAggregatedChapter]()
    
    private lazy var currentIndex: Int = {
        chaptersInfo.firstIndex { chapterInfo in
            chapterInfo.id == chapterId
        }!
    }()
    
    private func fetchData(withAggregate: Bool) async {
        ProgressHUD.animate()
        do {
            // 1) Fetch chapter model and statistics concurrently
            async let chapterModelTask = Requests.Chapter.get(id: chapterId)
            async let statisticsTask = Requests.Chapter.getStatistics(id: chapterId)
            let (chapterModel, statistics) = try await (chapterModelTask, statisticsTask)
            
            self.chapterModel = chapterModel
            self.statistics = statistics
            self.appBar.title = chapterModel.attributes.chapterName
            self.updateReadingStatus()
            
            // 2) Fetch page data and aggregated chapters concurrently depending on withAggregate
            async let pagesTask = Requests.Chapter.getPageData(chapterId: chapterModel.id)
            let aggregated: MangaAggregatedModel
            if withAggregate {
                let agg = try await Requests.Manga.getAggregatedChapters(
                    mangaId: chapterModel.mangaId!,
                    groupId: chapterModel.relationships.group?.id,
                    language: chapterModel.attributes.translatedLanguage
                )
                aggregated = agg
            } else {
                aggregated = self.aggregatedModel
            }
            let pagesModel = try await pagesTask
            
            // 3) Apply model data to UI
            self.pageURLs = pagesModel.pageURLs
            self.vSlider.maximumValue = Float(max(0, self.pageURLs.count - 1))
            self.aggregatedModel = aggregated
            
            if self.currentIndex == 0 {
                self.btnPrev.isEnabled = false
                self.btnPrev.setTitleColor(.darkGray808080, for: .normal)
            }
            if self.currentIndex == self.chaptersInfo.count - 1 {
                self.btnNext.isEnabled = false
                self.btnNext.setTitleColor(.darkGray808080, for: .normal)
            }
            
            self.setupChapterList()
            
            self.vPages.reloadData()
            self.toggleControlArea()
            ProgressHUD.dismiss()
        } catch {
            ProgressHUD.failed()
        }
    }
    
    override func getPreviousViewController() -> MangaViewer? {
        guard let chapterInfo = self.chaptersInfo.get(self.currentIndex - 1) else {
            return nil
        }
        return OnlineMangaViewer(
            mangaModel: self.mangaModel,
            chapterId: chapterInfo.id,
            aggregatedModel: self.aggregatedModel
        )
    }
    
    override func getNextViewController() -> MangaViewer? {
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
        let cellRegistration = UICollectionView.CellRegistration<
            MangaViewerChapterListCell, String
        > { [weak self] cell, indexPath, itemIdentifier in
            guard
                let self,
                let chapterInfo = chaptersInfo.first(
                    where: { $0.id == itemIdentifier
                    })
            else { return }
            cell.setContent(
                title: "mangaViewer.chapterList.chapterName"
                    .localizedFormat(chapterInfo.chapter),
                isCurrent: itemIdentifier == self.chapterId)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<MangaViewerChapterListHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader)
        { [weak self] supplementaryView, elementKind, indexPath in
            guard let self else { return }
            let title: String
            if let volumeNumber = Int(self.aggregatedModel.volumeNames[indexPath.section]) {
                title = "mangaViewer.chapterList.volumeName".localizedFormat(volumeNumber)
            } else {
                title = "mangaViewer.chapterList.noVolume".localized()
            }
            supplementaryView.setTitle(title)
        }
        
        chapterListDataSource = UICollectionViewDiffableDataSource<String, String>(
            collectionView: chapterListView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        chapterListDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<String, String>()
        snapshot.appendSections(aggregatedModel.volumeNames)
        for volume in aggregatedModel.volumeNames {
            snapshot
                .appendItems(
                    aggregatedModel
                        .volumes[volume]!.sortedChapters
                        .map { $0.id },
                    toSection: volume
                )
        }
        chapterListDataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.scrollChapterListToCurrentChapter(animated: false)
        }
    }

    override func chapterListWillShow() {
        super.chapterListWillShow()
        scrollChapterListToCurrentChapter(animated: false)
    }

    private var currentChapterListIndexPath: IndexPath? {
        guard let aggregatedModel else {
            return nil
        }
        for (section, volumeName) in aggregatedModel.volumeNames.enumerated() {
            guard let chapters = aggregatedModel.volumes[volumeName]?.sortedChapters,
                  let item = chapters.firstIndex(where: { $0.id == chapterId })
            else {
                continue
            }
            return IndexPath(item: item, section: section)
        }
        return nil
    }

    private func scrollChapterListToCurrentChapter(animated: Bool) {
        guard let indexPath = currentChapterListIndexPath else {
            return
        }
        guard chapterListView.numberOfSections > indexPath.section,
              chapterListView.numberOfItems(inSection: indexPath.section) > indexPath.item
        else {
            return
        }
        chapterListView.layoutIfNeeded()
        chapterListView.scrollToItem(
            at: indexPath,
            at: .centeredVertically,
            animated: animated
        )
    }
    
    // MARK: - Actions
    
    /// Mark the current chapter as **read** to the Mangadex server,
    /// and save the status in MDMangaProgressManager so that users can return to their last read chapter.
    private func updateReadingStatus() {
        if let mangaId = chapterModel?.mangaId {
            Task {
                try await Requests.Chapter.markAsRead(mangaID: mangaId, chapterID: chapterId)
            }
            MDMangaProgressManager.saveProgress(forMangaId: mangaId, chapterId: chapterId)
        }
    }
    
    @objc private func downloadChapter() {
        Task {
            await DownloadManager.shared
                .downloadChapter(mangaModel: mangaModel, chapterModel: chapterModel, pageURLs: pageURLs)
        }
        ProgressHUD.succeed("kInfoMessageAddedDownload".localized())
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
                Task {
                    let statistics = try await Requests.Chapter.createForumThread(chapterId: self.chapterId)
                    self.statistics = statistics
                    self.openForum()
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func openForum() {
        if let threadId = self.statistics.comments?.threadId,
           let url = URL(string: "https://forums.mangadex.org/threads/\(threadId)") {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true)
        }
    }
}

extension OnlineMangaViewer {
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if 
            collectionView == chapterListView,
            let cell = collectionView.cellForItem(at: indexPath) as? MangaViewerChapterListCell
        {
            cell.setHighlighted(true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if 
            collectionView == chapterListView,
            let cell = collectionView.cellForItem(at: indexPath) as? MangaViewerChapterListCell
        {
            cell.setHighlighted(false)
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

extension OnlineMangaViewer: MangaReadingContext {
    func getReadingContext() -> (
        mangaId: String,
        mangaTitle: String,
        coverURL: URL?,
        chapterId: String,
        chapterTitle: String
    ) {
        return (
            mangaModel.id,
            mangaModel.attributes.localizedTitle,
            mangaModel.coverURL,
            chapterModel.id,
            chapterModel.attributes.simpleChapterName
        )
    }
}
