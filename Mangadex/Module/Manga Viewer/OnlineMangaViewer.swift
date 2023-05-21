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

class OnlineMangaViewer: BaseViewController {
    
    // MARK: - views
    private lazy var refreshLeader: MJRefreshNormalLeader = {
        let leader = MJRefreshNormalLeader()
        leader.setTitle("kSlidePrevChapter".localized(), for: .idle)
        leader.setTitle("kReleasePrevChapter".localized(), for: .pulling)
        leader.setTitle("kLoading".localized(), for: .refreshing)
        leader.setArrowImage(UIImage(named: "icon_arrow_forward")!)

        leader.refreshingBlock = {
            guard let chapterInfo = self.chaptersInfo.get(self.currentIndex - 1) else {
                self.refreshLeader.endRefreshing()
                self.showNoChapterAlert()
                return
            }
            let vc = OnlineMangaViewer(
                mangaModel: self.mangaModel,
                chapterId: chapterInfo.id,
                aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, using: .leftIn)
        }
        return leader
    }()
    
    private lazy var refreshTrailer: MJRefreshNormalTrailer = {
        let trailer = MJRefreshNormalTrailer()
        trailer.setTitle("kSlideNextChapter".localized(), for: .idle)
        trailer.setTitle("kReleaseNextChapter".localized(), for: .pulling)
        trailer.setTitle("kLoading".localized(), for: .refreshing)
        trailer.setArrowImage(UIImage(named: "icon_arrow_back")!)
        
        trailer.refreshingBlock = {
            guard let chapterInfo = self.chaptersInfo.get(self.currentIndex + 1) else {
                self.refreshTrailer.endRefreshing()
                self.showNoChapterAlert()
                return
            }
            let vc = OnlineMangaViewer(
                mangaModel: self.mangaModel,
                chapterId: chapterInfo.id,
                aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, using: .rightIn)
        }
        return trailer
    }()
    
    lazy var vPages: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = MDLayout.screenSize
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        
        view.mj_leader = refreshLeader
        view.mj_trailer = refreshTrailer
        
        view.isPagingEnabled = true
        view.contentInsetAdjustmentBehavior = .never
        view.register(MangaPageCollectionCell.self, forCellWithReuseIdentifier: "page")
        
        let doubleTapRecognizer = MDShortTapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = MDShortTapGestureRecognizer.init(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        tapRecognizer.require(toFail: doubleTapRecognizer)
        view.addGestureRecognizer(tapRecognizer)
        
        return view
    }()
    
    lazy var vSlider = UISlider().apply { slider in
        slider.addTarget(self, action: #selector(handleSliderChange(_:)), for: .valueChanged)
    }
    
    let vBottomControl = UIView(backgroundColor: .black)
    lazy var btnPrev = UIButton(
        handler: {
            let vc = OnlineMangaViewer(
                mangaModel: self.mangaModel,
                chapterId: self.chaptersInfo[self.currentIndex - 1].id,
                aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, using: .leftIn)
        },
        title: "kSliderActionPrevChapter".localized(),
        titleColor: .white
    )
    lazy var btnNext = UIButton(
        handler: {
            let vc = OnlineMangaViewer(
                mangaModel: self.mangaModel,
                chapterId: self.chaptersInfo[self.currentIndex + 1].id,
                aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, using: .rightIn)
        },
        title: "kSliderActionNextChapter".localized(),
        titleColor: .white
    )
    
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
    
    convenience init(mangaModel: MDMangaItemDataModel, chapterId: String) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterId = chapterId
    }
    
    convenience init(
        mangaModel: MDMangaItemDataModel,
        chapterId: String,
        aggregatedModel: MDMangaAggregatedModel
    ) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterId = chapterId
        self.aggregatedModel = aggregatedModel
    }
    
    override func setupUI() {
        setupNavBar(backgroundColor: .black)
        
        view.backgroundColor = .black
        
        view.insertSubview(vPages, belowSubview: appBar)
        vPages.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(MDLayout.screenHeight)
        }
        
        view.insertSubview(vBottomControl, aboveSubview: vPages)
        vBottomControl.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.right.bottom.equalToSuperview()
        }
        
        vBottomControl.addSubview(btnPrev)
        btnPrev.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        vBottomControl.addSubview(btnNext)
        btnNext.snp.makeConstraints { make in
            make.centerY.equalTo(btnPrev)
            make.right.equalToSuperview().inset(16)
        }
        
        vBottomControl.addSubview(vSlider)
        vSlider.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.equalTo(btnPrev.snp.right).inset(-16)
            make.right.equalTo(btnNext.snp.left).inset(-16)
            make.centerY.equalTo(btnPrev)
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
    
    // MARK: - Data
    
    private var mangaModel: MDMangaItemDataModel!
    
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
    
    private var pageURLs: [URL] = []
    
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
            for fileName in pagesModel.chapter.data {
                if let pageURL = URL(string: "\(pagesModel.baseUrl!)/data/\(hash!)/\(fileName)") {
                    self.pageURLs.append(pageURL)
                }
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
    
    
    /// Mark the current chapter as **read** to the Mangadex server,
    /// and save the status in MDMangaProgressManager so that users can return to their last read chapter.
    private func updateReadingStatus() {
        if let mangaId = chapterModel?.mangaId {
            _ = MDRequests.Chapter.markAsRead(mangaId: mangaId, chapterId: chapterId)
            MDMangaProgressManager.saveProgress(forMangaId: mangaId, chapterId: chapterId)
        }
    }
    
    // MARK: - Bottom Controls
    
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
    
    // MARK: - Handlers
    
    @objc private func handleSingleTap(_ recognizer: MDShortTapGestureRecognizer) {
        let touchPointX = recognizer.location(in: view).x
        let leftEdge = MDLayout.vw(35)
        let rightEdge = MDLayout.vw(65)
        
        if touchPointX >= leftEdge && touchPointX <= rightEdge {
            toggleControlArea()
            return
        }
        
        guard let currentCell = vPages.visibleCells.first,
              let currentIndexPath = vPages.indexPath(for: currentCell) else {
            return
        }
        
        if touchPointX < leftEdge && currentIndexPath.item > 0 {
            hideControlArea()
            vPages.scrollToItem(
                at: .init(item: currentIndexPath.item - 1, section: currentIndexPath.section),
                at: .centeredHorizontally,
                animated: true
            )
        } else if touchPointX > rightEdge && currentIndexPath.item < pageURLs.count - 1 {
            hideControlArea()
            vPages.scrollToItem(
                at: .init(item: currentIndexPath.item + 1, section: currentIndexPath.section),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
    
    @objc private func handleDoubleTap(_ recognizer: MDShortTapGestureRecognizer) {
        if let currentCell = vPages.visibleCells.first {
            (currentCell as? MangaPageCollectionCell)?.handleTapGesture(recognizer)
        }
    }
    
    @objc private func handleSliderChange(_ slider: UISlider) {
        let newValue = round(slider.value)
        let newOffsetX = MDLayout.screenWidth * CGFloat(newValue)
        let curOffsetX = vPages.contentOffset.x
        if newOffsetX != curOffsetX {
            vPages.contentOffset = CGPoint(x: newOffsetX, y: 0)
        }
        slider.value = newValue
    }
    
    // MARK: - Actions
    
    private var isControlVisible = true
    private func toggleControlArea() {
        if isControlVisible {
            isControlVisible = false
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.appBar.transform = self.appBar.transform.translatedBy(x: 0, y: -self.appBar.frame.height)
                self.vBottomControl.transform = self.vBottomControl.transform
                    .translatedBy(x: 0, y: self.vBottomControl.frame.height)
                self.isStatusBarHidden = true
            }
        } else {
            isControlVisible = true
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.appBar.transform = self.appBar.transform.translatedBy(x: 0, y: self.appBar.frame.height)
                self.vBottomControl.transform = self.vBottomControl.transform
                    .translatedBy(x: 0, y: -self.vBottomControl.frame.height)
                self.isStatusBarHidden = false
            }
        }
    }
    
    private func hideControlArea() {
        if isControlVisible {
            toggleControlArea()
        }
    }
    
    private func showNoChapterAlert() {
        let alert = UIAlertController(
            title: "kInfo".localized(), message: "kNoChapterAlertMsg".localized(), preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "kCancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "kOk".localized(), style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }
}

// MARK: - CollectionViewDelegate
extension OnlineMangaViewer: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath)
        as! MangaPageCollectionCell
        cell.setImageUrl(pageURLs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageURLs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! MangaPageCollectionCell).resetScale()
        // update slider value when scrolled to a new page
        vSlider.value = Float(ceil(collectionView.contentOffset.x / MDLayout.screenWidth))
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer is UIPinchGestureRecognizer ||
            otherGestureRecognizer is UIPanGestureRecognizer ||
            otherGestureRecognizer is MDShortTapGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
}
