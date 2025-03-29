//
//  MangaViewerCollectionView.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/21.
//

import Foundation
import UIKit
import MJRefresh

protocol MangaViewerCollectionViewProvider: AnyObject {
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
        leader.refreshingBlock = { [unowned self] in
            self.refreshingBlockLeader?(leader)
        }
    }
    
    private lazy var refreshTrailer = MJRefreshNormalTrailer().apply { trailer in
        trailer.setTitle("kSlideNextChapter".localized(), for: .idle)
        trailer.setTitle("kReleaseNextChapter".localized(), for: .pulling)
        trailer.setTitle("kLoading".localized(), for: .refreshing)
        trailer.setArrowImage(UIImage(named: "icon_arrow_back")!)
        trailer.refreshingBlock = { [unowned self] in
            self.refreshingBlockTrailer?(trailer)
        }
    }
    
    weak var provider: MangaViewerCollectionViewProvider!
    
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
}
