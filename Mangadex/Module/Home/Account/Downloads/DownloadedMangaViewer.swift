//
//  DownloadedMangaViewer.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/15.
//

import Foundation
import UIKit
import SnapKit
import MJRefresh

class DownloadedMangaViewer: BaseViewController {
    private lazy var refreshLeader: MJRefreshNormalLeader = {
        let leader = MJRefreshNormalLeader()
        leader.setTitle("kSlidePrevChapter".localized(), for: .idle)
        leader.setTitle("kReleasePrevChapter".localized(), for: .pulling)
        leader.setTitle("kLoading".localized(), for: .refreshing)
        leader.setArrowImage(UIImage(named: "icon_arrow_forward")!)
        
        leader.refreshingBlock = {
            guard let nextChapterModel = self.mangaModel.chapters.get(self.currentIndex - 1) else {
                leader.endRefreshing()
                self.showNoChapterAlert()
                return
            }
            let vc = DownloadedMangaViewer(
                mangaModel: self.mangaModel, chapterModel: nextChapterModel
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
            guard let nextChapterModel = self.mangaModel.chapters.get(self.currentIndex + 1) else {
                trailer.endRefreshing()
                self.showNoChapterAlert()
                return
            }
            let vc = DownloadedMangaViewer(
                mangaModel: self.mangaModel, chapterModel: nextChapterModel
            )
            self.navigationController?.replaceTopViewController(with: vc, using: .rightIn)
        }
        return trailer
    }()
    
    private lazy var vPages: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = MDLayout.screenSize
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        
        view.mj_leader = refreshLeader
        view.mj_trailer = refreshTrailer
        
        view.isPagingEnabled = true
        view.contentInsetAdjustmentBehavior = .never
        view.register(
            MangaPageCollectionCell.self,
            forCellWithReuseIdentifier: "page"
        )
        
        let doubleTapRecognizer = MDShortTapGestureRecognizer(
            target: self, action: #selector(handleDoubleTap(_:))
        )
        doubleTapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTapRecognizer = MDShortTapGestureRecognizer(
            target: self, action: #selector(handleSingleTap(_:))
        )
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.delegate = self
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        view.addGestureRecognizer(singleTapRecognizer)
        
        return view
    }()
    
    private lazy var vSlider = UISlider().apply { slider in
        slider.maximumValue = Float(self.chapterModel.pageURLs.count - 1)
        slider.addTarget(
            self, action: #selector(handleSliderChange(_:)), for: .valueChanged
        )
    }
    private let vBottomControl = UIView(backgroundColor: .black)
    private lazy var btnPrev = UIButton(
        handler: {},
        title: "kSliderActionPrevChapter".localized(),
        titleColor: .white
    )
    private lazy var btnNext = UIButton(
        handler: {},
        title: "kSliderActionNextChapter".localized(),
        titleColor: .white
    )
    
    // MARK: - Lifecycle Methods
    convenience init(
        mangaModel: LocalMangaModel,
        chapterModel: LocalChapterModel
    ) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterModel = chapterModel
    }
    
    override func setupUI() {
        setupNavBar(
            title: chapterModel.info.attributes.chapterName,
            backgroundColor: .black
        )
        
        view.backgroundColor = .black
        
        view.insertSubview(vPages, belowSubview: appBar)
        vPages.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(MDLayout.screenHeight)
        }
        
        view.insertSubview(vBottomControl, aboveSubview: vPages)
        vBottomControl.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        vBottomControl.addSubview(vSlider)
        vSlider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(MDLayout.adjustedSafeInsetBottom)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleControlArea()
    }
    
    // MARK: - Properties
    private var mangaModel: LocalMangaModel!
    private var chapterModel: LocalChapterModel!
    
    private lazy var currentIndex: Int = {
        mangaModel.chapters.firstIndex { model in
            model == self.chapterModel
        }!
    }()
    
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
        } else if touchPointX > rightEdge && currentIndexPath.item < chapterModel.pageURLs.count - 1 {
            hideControlArea()
            vPages.scrollToItem(
                at: .init(item: currentIndexPath.item + 1, section: currentIndexPath.section),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
    
    @objc private func handleDoubleTap(_ recognizer: MDShortTapGestureRecognizer) {
        if let currentCell = vPages.visibleCells.first as? MangaPageCollectionCell {
            currentCell.handleTapGesture(recognizer)
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

extension DownloadedMangaViewer: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chapterModel.pageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! MangaPageCollectionCell
        cell.setImageUrl(chapterModel.pageURLs[indexPath.row])
        return cell
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
