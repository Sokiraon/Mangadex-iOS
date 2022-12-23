//
//  MDMangaSlideViewController.swift
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

class MDMangaSlideViewController: MDViewController {
    
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
                return
            }
            let vc = MDMangaSlideViewController(
                chapterId: chapterInfo.id, aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, animation: .leftIn)
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
                self.refreshLeader.endRefreshing()
                return
            }
            let vc = MDMangaSlideViewController(
                chapterId: chapterInfo.id, aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, animation: .rightIn)
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
        view.register(MDMangaSlideCollectionCell.self, forCellWithReuseIdentifier: "page")
        
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
    
    lazy var vSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    let vBottomControl = UIView(backgroundColor: .black)
    lazy var btnPrev = UIButton(
        handler: {
            let vc = MDMangaSlideViewController(
                chapterId: self.chaptersInfo[self.currentIndex - 1].id,
                aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, animation: .leftIn)
        },
        title: "kSliderActionPrevChapter".localized(),
        titleColor: .white
    )
    lazy var btnNext = UIButton(
        handler: {
            let vc = MDMangaSlideViewController(
                chapterId: self.chaptersInfo[self.currentIndex + 1].id,
                aggregatedModel: self.aggregatedModel
            )
            self.navigationController?.replaceTopViewController(with: vc, animation: .rightIn)
        },
        title: "kSliderActionNextChapter".localized(),
        titleColor: .white
    )
    
    // MARK: - Lifecycle methods
    
    convenience init(chapterId: String) {
        self.init()
        self.chapterId = chapterId
    }
    
    convenience init(chapterId: String, aggregatedModel: MDMangaAggregatedModel) {
        self.init()
        self.chapterId = chapterId
        self.aggregatedModel = aggregatedModel
    }
    
    override func setupUI() {
        setupNavBar()
        appBar.backgroundColor = .black
        
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
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.bottom.equalTo(-MDLayout.safeInsetBottom)
        }
        
        vBottomControl.addSubview(btnNext)
        btnNext.snp.makeConstraints { make in
            make.centerY.equalTo(btnPrev)
            make.right.equalTo(-15)
        }
        
        vBottomControl.addSubview(vSlider)
        vSlider.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.equalTo(btnPrev.snp.right).offset(15)
            make.right.equalTo(btnNext.snp.left).offset(-15)
            make.centerY.equalTo(btnPrev)
        }
    }
    
    override func didSetupUI() {
        fetchData(withAggregate: aggregatedModel == nil)
    }
    
    // MARK: - Data
    
    private var chapterId: String!
    private var chapterModel: MDMangaChapterModel!
    
    private var aggregatedModel: MDMangaAggregatedModel!
    private var chaptersInfo: [MDMangaAggregatedChapter] {
        aggregatedModel.chapters
    }
    
    private var currentIndex: Int {
        chaptersInfo.firstIndex { chapterInfo in
            chapterInfo.id == chapterId
        } ?? 0
    }
    private var pages: [String] = []
    
    private func fetchData(withAggregate: Bool) {
        ProgressHUD.show()
        firstly {
            MDRequests.Chapter.get(id: chapterId)
        }.then { chapterModel in
            self.chapterModel = chapterModel
            self.appBar.title = chapterModel.attributes.chapterName
            if let mangaId = chapterModel.mangaId {
                MDMangaProgressManager.saveProgress(forMangaId: mangaId, chapterId: self.chapterId)
            }
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
                self.pages.append("\(pagesModel.baseUrl!)/data/\(hash!)/\(fileName)")
            }
            // Set up slider range based on page count
            if self.pages.count > 0 {
                self.vSlider.maximumValue = Float(self.pages.count - 1) / Float(self.pages.count)
            } else {
                self.vSlider.maximumValue = 0
            }
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
                self.showHideControlArea()
                ProgressHUD.dismiss()
            }
        }.catch { error in
            DispatchQueue.main.async {
                ProgressHUD.showError()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleSingleTap(_ recognizer: MDShortTapGestureRecognizer) {
        let touchPointX = recognizer.location(in: view).x
        let leftEdge = MDLayout.vw(35)
        let rightEdge = MDLayout.vw(65)
        
        if touchPointX >= leftEdge && touchPointX <= rightEdge {
            showHideControlArea()
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
        } else if touchPointX > rightEdge && currentIndexPath.item < pages.count - 1 {
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
            (currentCell as? MDMangaSlideCollectionCell)?.handleTapGesture(recognizer)
        }
    }
    
    private func showHideControlArea() {
        if (appBar.isHidden == true) {
            appBar.isHidden = false
            vBottomControl.isHidden = false
            let transform = appBar.transform.translatedBy(x: 0, y: appBar.frame.height)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.appBar.transform = transform
                self.vBottomControl.transform = self.vBottomControl.transform
                    .translatedBy(x: 0, y: -self.vBottomControl.frame.height)
            }
        } else {
            hideControlArea()
        }
    }
    
    private func hideControlArea() {
        if (appBar.isHidden == false) {
            let transform = appBar.transform.translatedBy(x: 0, y: -appBar.frame.height)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.appBar.transform = transform
                self.vBottomControl.transform = self.vBottomControl.transform
                    .translatedBy(x: 0, y: self.vBottomControl.frame.height)
            } completion: { status in
                self.appBar.isHidden = true
                self.vBottomControl.isHidden = true
            }
        }
    }
    
    @objc private func handleSliderChange() {
        let newValue = vSlider.value
        if (newValue < 1) {
            let newIndex = floor(newValue * Float(pages.count))
            let targetOffsetX = MDLayout.screenWidth * CGFloat(newIndex)
            let currentOffsetX = vPages.contentOffset.x
            if (targetOffsetX != currentOffsetX) {
                vPages.contentOffset = CGPoint(x: targetOffsetX, y: 0)
            }
        }
    }
}

// MARK: - CollectionViewDelegate
extension MDMangaSlideViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath)
        as! MDMangaSlideCollectionCell
        cell.setImageUrl(pages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! MDMangaSlideCollectionCell).resetScale()
        // update slider value when scrolled to a new page
        vSlider.value = Float(ceil(collectionView.contentOffset.x / MDLayout.screenWidth) / CGFloat(pages.count))
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
