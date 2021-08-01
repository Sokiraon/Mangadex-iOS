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

class MDMangaSlideViewController: MDViewController {
    // MARK: - properties
    var pages: [String] = []
    var dataModel: MDMangaChapterDataModel!
    var currentIndex: Int!
    
    private lazy var refreshLeader: MJRefreshNormalLeader = {
        let leader = MJRefreshNormalLeader()
        leader.setTitle("kSlidePrevChapter".localized(), for: .idle)
        leader.setTitle("kReleasePrevChapter".localized(), for: .pulling)
        leader.setTitle("kLoading".localized(), for: .refreshing)
        leader.setArrowImage(UIImage(named: "baseline_arrow_forward_black_18pt")!)
        
        leader.refreshingBlock = {
            let dataModel = self.requirePrev(self.currentIndex)
            if (dataModel == nil) {
                self.refreshLeader.endRefreshing()
            } else {
                let vc = MDMangaSlideViewController.initWithChapterData(
                    dataModel!,
                    currentIndex: self.currentIndex - 1,
                    requirePrevAction: self.requirePrev,
                    requireNextAction: self.requireNext
                )
                self.refreshLeader.endRefreshing()
                self.navigationController?.replaceTopViewController(with: vc, animation: .leftIn)
            }
        }
        return leader
    }()
    
    private lazy var refreshTrailer: MJRefreshNormalTrailer = {
        let trailer = MJRefreshNormalTrailer()
        trailer.setTitle("kSlideNextChapter".localized(), for: .idle)
        trailer.setTitle("kReleaseNextChapter".localized(), for: .pulling)
        trailer.setTitle("kLoading".localized(), for: .refreshing)
        trailer.setArrowImage(UIImage(named: "baseline_arrow_back_black_18pt")!)
        
        trailer.refreshingBlock = {
            let dataModel = self.requireNext(self.currentIndex)
            if (dataModel == nil) {
                self.refreshTrailer.endRefreshing()
            } else {
                let vc = MDMangaSlideViewController.initWithChapterData(
                        dataModel!,
                        currentIndex: self.currentIndex + 1,
                        requirePrevAction: self.requirePrev,
                        requireNextAction: self.requireNext
                )
                self.refreshTrailer.endRefreshing()
                self.navigationController?.replaceTopViewController(with: vc, animation: .rightIn)
            }
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
            let vc = MDMangaSlideViewController.initWithChapterData(
                self.requirePrev(self.currentIndex)!,
                currentIndex: self.currentIndex - 1,
                requirePrevAction: self.requirePrev,
                requireNextAction: self.requireNext
            )
            vc.leavePageAction = self.leavePageAction
            self.navigationController?.replaceTopViewController(with: vc, animation: .leftIn)
        },
        title: "kSliderActionPrevChapter".localized(),
        titleColor: .white
    )
    lazy var btnNext = UIButton(
        handler: {
            let vc = MDMangaSlideViewController.initWithChapterData(
                self.requireNext(self.currentIndex)!,
                currentIndex: self.currentIndex + 1,
                requirePrevAction: self.requirePrev,
                requireNextAction: self.requireNext
            )
            vc.leavePageAction = self.leavePageAction
            self.navigationController?.replaceTopViewController(with: vc, animation: .rightIn)
        },
        title: "kSliderActionNextChapter".localized(),
        titleColor: .white
    )
    
    var requirePrev: ((_ index: Int) -> MDMangaChapterDataModel?)!
    var requireNext: ((_ index: Int) -> MDMangaChapterDataModel?)!
    
    var leavePageAction: ((_ chapter: String) -> Void)!
    
    // MARK: - initialize
    static func initWithChapterData(_ dataModel: MDMangaChapterDataModel,
                                    currentIndex index: Int,
                                    requirePrevAction requirePrev: ((_ index: Int) -> MDMangaChapterDataModel?)!,
                                    requireNextAction requireNext: ((_ index: Int) -> MDMangaChapterDataModel?)!
    ) -> MDMangaSlideViewController {
        let vc = MDMangaSlideViewController()
        if (dataModel.data.attributes.title == nil || dataModel.data.attributes.title == "") {
            vc.viewTitle = "\(dataModel.data.attributes.chapter!) \("kChapter".localized())"
        } else {
            vc.viewTitle = dataModel.data.attributes.title!
        }
        vc.dataModel = dataModel
        vc.currentIndex = index
        
        vc.requirePrev = requirePrev
        vc.requireNext = requireNext
        
        return vc
    }
    
    override func setupUI() {
        setupNavBar(preserveStatus: false, backgroundColor: .black)
        
        view.backgroundColor = .black
        
        view.insertSubview(vPages, belowSubview: appBar!)
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
        
        if (requirePrev(currentIndex) == nil) {
            btnPrev.isEnabled = false
            btnPrev.setTitleColor(MDColor.get(.darkGray808080), for: .normal)
        }
        if (requireNext(currentIndex) == nil) {
            btnNext.isEnabled = false
            btnNext.setTitleColor(MDColor.get(.darkGray808080), for: .normal)
        }
    }
    
    override func didSetupUI() {
        ProgressHUD.show()
        MDHTTPManager.getInstance()
                .getChapterBaseUrlById(dataModel.data.id) { url in
                    for fileName in self.dataModel.data.attributes.data {
                        self.pages.append(
                                "\(url)/data/\(self.dataModel.data.attributes.chapterHash!)/\(fileName)"
                        )
                    }
                    DispatchQueue.main.async {
                        self.vSlider.maximumValue = Float(self.pages.count - 1) / Float(self.pages.count)
                        self.vPages.reloadData()
                        self.showHideControlArea()
                        ProgressHUD.dismiss()
                    }
                }
    }
    
    @objc private func handleSingleTap(_ recognizer: MDShortTapGestureRecognizer) {
        let touchPointX = recognizer.location(in: view).x
        let screenWidth = MDLayout.screenWidth
        let leftEdge = screenWidth / 2 - MDLayout.vw(15)
        let rightEdge = screenWidth / 2 + MDLayout.vw(15)
        
        let contentOffset = vPages.contentOffset
        if (touchPointX < leftEdge && contentOffset.x >= screenWidth) {
            hideControlArea()
            vPages.contentOffset = CGPoint(x: contentOffset.x - screenWidth, y: contentOffset.y)
        } else if (touchPointX > rightEdge && contentOffset.x < vPages.contentSize.width - screenWidth) {
            hideControlArea()
            vPages.contentOffset = CGPoint(x: contentOffset.x + screenWidth, y: contentOffset.y)
        } else if (touchPointX >= leftEdge && touchPointX <= rightEdge) {
            showHideControlArea()
        }
    }
    
    @objc private func handleDoubleTap(_ recognizer: MDShortTapGestureRecognizer) {
        let cells = vPages.visibleCells
        (cells[0] as! MDMangaSlideCollectionCell).handleTapGesture(recognizer)
    }
    
    private func showHideControlArea() {
        if (appBar?.isHidden == true) {
            appBar?.isHidden = false
            vBottomControl.isHidden = false
            let transform = appBar?.transform.translatedBy(x: 0, y: (appBar?.frame.height)!)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.appBar?.transform = transform!
                self.vBottomControl.transform = self.vBottomControl.transform
                        .translatedBy(x: 0, y: -self.vBottomControl.frame.height)
            }
        } else {
            hideControlArea()
        }
    }
    
    private func hideControlArea() {
        if (appBar?.isHidden == false) {
            let transform = appBar?.transform.translatedBy(x: 0, y: -(appBar?.frame.height)!)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.appBar?.transform = transform!
                self.vBottomControl.transform = self.vBottomControl.transform
                        .translatedBy(x: 0, y: self.vBottomControl.frame.height)
            } completion: { status in
                self.appBar?.isHidden = true
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
    
    override func willLeavePage() {
        leavePageAction(dataModel.data.attributes.chapter)
    }
}

// MARK: - collectionView
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
        vSlider.value = Float(ceil(collectionView.contentOffset.x / MDLayout.screenWidth) / CGFloat(pages.count))
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer is UIPanGestureRecognizer ||
            otherGestureRecognizer is MDShortTapGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
}
