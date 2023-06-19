//
//  MangaViewer.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/21.
//

import Foundation
import UIKit
import MJRefresh
import SnapKit

class MangaViewer: BaseViewController,
                   UIGestureRecognizerDelegate,
                   UICollectionViewDelegate,
                   MangaViewerCollectionViewProvider {
    
    private lazy var doubleTapRecognizer = ShortTapGestureRecognizer(
        target: self, action: #selector(handleDoubleTap(_:))
    ).apply { recognizer in
        recognizer.numberOfTapsRequired = 2
    }
    
    private lazy var singleTapRecognizer = ShortTapGestureRecognizer(
        target: self, action: #selector(handleSingleTap(_:))
    ).apply { recognizer in
        recognizer.numberOfTapsRequired = 1
        recognizer.delegate = self
        recognizer.require(toFail: doubleTapRecognizer)
    }
    
    internal lazy var vPages = MangaViewerCollectionView(provider: self).apply { view in
        view.delegate = self
        view.addGestureRecognizer(doubleTapRecognizer)
        view.addGestureRecognizer(singleTapRecognizer)
        view.refreshingBlockLeader = { leader in
            guard let vc = self.previousViewController else {
                leader.endRefreshing()
                self.showNoChapterAlert()
                return
            }
            self.navigationController?.replaceTopViewController(with: vc, using: .leftIn)
        }
        view.refreshingBlockTrailer = { trailer in
            guard let vc = self.nextViewController else {
                trailer.endRefreshing()
                self.showNoChapterAlert()
                return
            }
            self.navigationController?.replaceTopViewController(with: vc, using: .rightIn)
        }
    }
    
    internal let vBottomControl = UIView().apply { view in
        view.backgroundColor = .black
    }
    internal lazy var vSlider = UISlider().apply { slider in
        slider.addTarget(self, action: #selector(handleSliderChange(_:)), for: .valueChanged)
    }
    internal lazy var btnPrev = UIButton(
        title: "kSliderActionPrevChapter".localized(),
        titleColor: .white,
        backgroundColor: nil,
        action: UIAction { _ in
            if let vc = self.previousViewController {
                self.navigationController?.replaceTopViewController(with: vc, using: .leftIn)
            }
        }
    )
    internal lazy var btnNext = UIButton(
        title: "kSliderActionNextChapter".localized(),
        titleColor: .white,
        backgroundColor: nil,
        action: UIAction { _ in
            if let vc = self.nextViewController {
                self.navigationController?.replaceTopViewController(with: vc, using: .rightIn)
            }
        }
    )
    
    override func setupUI() {
        view.backgroundColor = .black
        setupNavBar(backgroundColor: .black)
        
        view.insertSubview(vPages, belowSubview: appBar)
        vPages.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(MDLayout.screenHeight)
        }
        
        view.insertSubview(vBottomControl, aboveSubview: vPages)
        vBottomControl.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Chapter List
    
    internal var chapterListView: UICollectionView!
    internal var chapterListDataSource: UICollectionViewDiffableDataSource<String, MDMangaAggregatedVolumeChapter>!
    
    private var showsChapterList = false
    internal func showHideChapterList() {
        if showsChapterList {
            UIView.animate(withDuration: 0.25) {
                self.chapterListView.transform = self.chapterListView.transform
                    .translatedBy(x: self.chapterListView.frame.width, y: 0)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.chapterListView.transform = self.chapterListView.transform
                    .translatedBy(x: -self.chapterListView.frame.width, y: 0)
            }
        }
        self.showsChapterList = !self.showsChapterList
    }
    
    // MARK: - Properties
    
    var pageURLs: [URL] = []
    
    internal var previousViewController: MangaViewer? {
        nil
    }
    internal var nextViewController: MangaViewer? {
        nil
    }
    
    // MARK: - Handlers
    
    @objc private func handleSingleTap(_ recognizer: ShortTapGestureRecognizer) {
        if showsChapterList {
            showHideChapterList()
            toggleControlArea()
            return
        }
        
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
    
    @objc private func handleDoubleTap(_ recognizer: ShortTapGestureRecognizer) {
        if let currentCell = vPages.visibleCells.first as? MangaViewerCollectionCell {
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
    internal func toggleControlArea() {
        if isControlVisible {
            isControlVisible = false
            UIView.animate(withDuration: 0.25) {
                self.appBar.transform = self.appBar.transform.translatedBy(x: 0, y: -self.appBar.frame.height)
                self.vBottomControl.transform = self.vBottomControl.transform
                    .translatedBy(x: 0, y: self.vBottomControl.frame.height)
                self.isStatusBarHidden = true
            }
        } else {
            isControlVisible = true
            UIView.animate(withDuration: 0.25) {
                self.appBar.transform = self.appBar.transform.translatedBy(x: 0, y: self.appBar.frame.height)
                self.vBottomControl.transform = self.vBottomControl.transform
                    .translatedBy(x: 0, y: -self.vBottomControl.frame.height)
                self.isStatusBarHidden = false
            }
        }
    }
    
    internal func hideControlArea() {
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
    
    // MARK: - Delegate Methods
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == vPages {
            (cell as? MangaViewerCollectionCell)?.resetScale()
            // update slider value when scrolled to a new page
            vSlider.value = Float(ceil(collectionView.contentOffset.x / MDLayout.screenWidth))
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer is UIPinchGestureRecognizer ||
            otherGestureRecognizer is UIPanGestureRecognizer ||
            otherGestureRecognizer is ShortTapGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
}
