//
//  MDMangaListViewController.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit
import ProgressHUD
import MJRefresh
import SnapKit

class MDMangaListViewController: MDViewController {

    final let vTopArea = UIView()
    
    internal var mangaList = [MDMangaItemDataModel]()
    internal var mangaTotal = 0
    
    internal lazy var vCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let view = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(MDMangaListCollectionCell.self, forCellWithReuseIdentifier: "mangaCell")
        view.register(MDCollectionLoaderCell.self, forCellWithReuseIdentifier: "loader")
        view.contentInset = .cssStyle(5, 10)
        view.backgroundColor = .clear
        return view
    }()
    
    internal lazy var refreshHeader = MJRefreshNormalHeader {
        self.fetchData()
    }
    
    /// Called when user pulls the refresh header.
    /// Should be overrideen by sub-classes to request initial data from the source.
    internal func fetchData() {}
    /// Called when the loader view enters screen.
    /// Should be overridden by sub-classes to request following data from the source to achieve infinite scrolling.
    internal func loadMoreData() {}
    
    internal func reloadCollection() {
        DispatchQueue.main.async {
            self.vCollection.reloadData()
            self.vCollection.setNeedsLayout()
            self.vCollection.layoutIfNeeded()
        }
    }
    
    override func setupUI() {
        view.addSubview(vTopArea)
        vTopArea.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        view.insertSubview(vCollection, belowSubview: vTopArea)
        vCollection.mj_header = refreshHeader
        vCollection.snp.makeConstraints { make in
            make.top.equalTo(vTopArea.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        refreshHeader.beginRefreshing()
    }
}


// MARK: - UICollectionView Delegate Methods
extension MDMangaListViewController: UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {
    enum CollectionSection: Int {
        case mangaList
        case loader
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let section = CollectionSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .mangaList:
            return mangaList.count
        case .loader:
            return mangaList.count < mangaTotal ? 1 : 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch section {
        case .mangaList:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "mangaCell",
                for: indexPath
            )
            (cell as! MDMangaListCollectionCell).update(mangaModel: mangaList[indexPath.row])
            return cell
        case .loader:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "loader",
                for: indexPath
            )
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return
        }
        if section == .loader {
            loadMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MDMangaDetailViewController(mangaModel: mangaList[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
