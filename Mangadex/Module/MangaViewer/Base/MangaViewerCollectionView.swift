//
//  MangaViewerCollectionView.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/21.
//

import Foundation
import UIKit
import MJRefresh

protocol MangaViewerCollectionViewProvider {
    var pageURLs: [URL] { get set }
}

class MangaViewerCollectionView: UICollectionView, UICollectionViewDataSource {
    
    var refreshingBlockLeader: ((_ leader: MJRefreshNormalLeader) -> Void)?
    var refreshingBlockTrailer: ((_ trailer: MJRefreshNormalTrailer) -> Void)?
    
    private lazy var refreshLeader = MJRefreshNormalLeader().apply { leader in
        leader.setTitle("kSlidePrevChapter".localized(), for: .idle)
        leader.setTitle("kReleasePrevChapter".localized(), for: .pulling)
        leader.setTitle("kLoading".localized(), for: .refreshing)
        leader.setArrowImage(UIImage(named: "icon_arrow_forward")!)
        leader.refreshingBlock = {
            self.refreshingBlockLeader?(leader)
        }
    }
    
    private lazy var refreshTrailer = MJRefreshNormalTrailer().apply { trailer in
        trailer.setTitle("kSlideNextChapter".localized(), for: .idle)
        trailer.setTitle("kReleaseNextChapter".localized(), for: .pulling)
        trailer.setTitle("kLoading".localized(), for: .refreshing)
        trailer.setArrowImage(UIImage(named: "icon_arrow_back")!)
        trailer.refreshingBlock = {
            self.refreshingBlockTrailer?(trailer)
        }
    }
    
    private var provider: MangaViewerCollectionViewProvider
    
    init(provider: MangaViewerCollectionViewProvider) {
        self.provider = provider
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = MDLayout.screenSize
        super.init(frame: .zero, collectionViewLayout: layout)
        
        mj_leader = refreshLeader
        mj_trailer = refreshTrailer
        
        dataSource = self
        isPagingEnabled = true
        contentInsetAdjustmentBehavior = .never
        register(
            MangaViewerCollectionCell.self,
            forCellWithReuseIdentifier: "cell"
        )
    }
    
//    init(delegate: MangaViewerCollectionViewDelegate) {
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        layout.itemSize = MDLayout.screenSize
//        super.init(frame: .zero, collectionViewLayout: layout)
//
//        mj_leader = refreshLeader
//        self.delegate = self
//        self.dataSource = self
//
//        isPagingEnabled = true
//        contentInsetAdjustmentBehavior = .never
//        register(
//            MangaViewerCollectionCell.self,
//            forCellWithReuseIdentifier: "page"
//        )
//
//        let doubleTapRecognizer = ShortTapGestureRecognizer(
//            target: self, action: #selector(handleDoubleTap(_:))
//        )
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        addGestureRecognizer(doubleTapRecognizer)
//
//        let singleTapRecognizer = ShortTapGestureRecognizer(
//            target: self, action: #selector(handleSingleTap(_:))
//        )
//        singleTapRecognizer.numberOfTapsRequired = 1
//        singleTapRecognizer.delegate = self
//        singleTapRecognizer.require(toFail: doubleTapRecognizer)
//        addGestureRecognizer(singleTapRecognizer)
//    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        provider.pageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell", for: indexPath
        ) as! MangaViewerCollectionCell
        cell.imageURL = provider.pageURLs[indexPath.item]
        return cell
    }
    
//    @objc private func handleSingleTap(_ recognizer: ShortTapGestureRecognizer) {
//        let touchPointX = recognizer.location(in: nil).x
//        let leftEdge = MDLayout.vw(35)
//        let rightEdge = MDLayout.vw(65)
//
//        if touchPointX >= leftEdge && touchPointX <= rightEdge {
//            return
//        }
//
//        guard let currentCell = visibleCells.first,
//              let currentIndexPath = indexPath(for: currentCell) else {
//            return
//        }
//
//        if touchPointX < leftEdge && currentIndexPath.item > 0 {
//            scrollToItem(
//                at: .init(item: currentIndexPath.item - 1, section: currentIndexPath.section),
//                at: .centeredHorizontally,
//                animated: true
//            )
//        } else if touchPointX > rightEdge && currentIndexPath.item < viewDelegate.pageURLs.count - 1 {
//            scrollToItem(
//                at: .init(item: currentIndexPath.item + 1, section: currentIndexPath.section),
//                at: .centeredHorizontally,
//                animated: true
//            )
//        }
//    }
//
//    @objc private func handleDoubleTap(_ recognizer: ShortTapGestureRecognizer) {
//        if let currentCell = visibleCells.first as? MangaViewerCollectionCell {
//            currentCell.handleTapGesture(recognizer)
//        }
//    }
}

//extension MangaViewerCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        viewDelegate.pageURLs.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! MangaViewerCollectionCell
//        cell.setImageUrl(viewDelegate.pageURLs[indexPath.item])
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        (cell as! MangaViewerCollectionCell).resetScale()
//    }
//
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if (otherGestureRecognizer is UIPinchGestureRecognizer ||
//            otherGestureRecognizer is UIPanGestureRecognizer ||
//            otherGestureRecognizer is ShortTapGestureRecognizer) {
//            return true
//        } else {
//            return false
//        }
//    }
//}
