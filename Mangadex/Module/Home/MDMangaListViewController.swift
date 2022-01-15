//
//  MDMangaListViewController.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit
import ProgressHUD

fileprivate let cellMargin = 10.0

class MDMangaListViewController: MDViewController {
    
    lazy var vCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(
            width: MDLayout.screenWidth - cellMargin * 2,
            height: MDMangaListCollectionCell.cellHeight
        )
        layout.minimumLineSpacing = 10
        
        let view = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(MDMangaListCollectionCell.self, forCellWithReuseIdentifier: "mangaCell")
        view.contentInset = UIEdgeInsets(value: "5 \(cellMargin)")
        view.backgroundColor = .clear
        return view
    }()
    
    var mangaList = [MangaItem]()
    
    lazy var refreshHeader = MJRefreshNormalHeader {
        self.onHeaderRefresh()
    }
    lazy var refreshFooter = MJRefreshBackNormalFooter {
        self.onFooterRefresh()
    }
    
    func onHeaderRefresh() {
    }
    
    func onFooterRefresh() {
    }
    
    override func setupUI() {
        view.addSubview(vCollection)
        vCollection.snp.makeConstraints { make in
            make.top.equalTo(MDLayout.safeInsetTop)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        vCollection.mj_header = refreshHeader
        vCollection.mj_footer = refreshFooter
        vCollection.mj_footer?.isHidden = true
        
        refreshHeader.beginRefreshing()
    }
}


// MARK: Delegate Methods

extension MDMangaListViewController: UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        mangaList.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "mangaCell",
            for: indexPath
        )
        (cell as! MDMangaListCollectionCell).setContent(mangaItem: mangaList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let vc = MDMangaDetailViewController(
            mangaItem: mangaList[indexPath.row],
            title: (cell as! MDMangaListCollectionCell).getTitle()
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}
