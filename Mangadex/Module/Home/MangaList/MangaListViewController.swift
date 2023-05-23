//
//  MangaListViewController.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit
import ProgressHUD
import MJRefresh
import SnapKit

class MangaListViewController: BaseViewController {

    final let vTopArea = UIView()
    
    internal var mangaList = [MangaItemDataModel]()
    
    internal lazy var vCollection = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).apply { view in
        view.delegate = self
        view.register(MangaListCollectionCell.self, forCellWithReuseIdentifier: "mangaCell")
        view.register(MDCollectionLoaderCell.self, forCellWithReuseIdentifier: "loader")
        view.contentInset = .cssStyle(5, 10)
        view.mj_header = refreshHeader
    }
    
    internal lazy var refreshHeader = MJRefreshNormalHeader {
        self.fetchData()
    }
    
    /// Called when user pulls the refresh header.
    /// Must be overrideen by sub-classes to request initial data from the source.
    internal func fetchData() {
        fatalError()
    }
    /// Called when the loader view enters screen.
    /// Must be overridden by sub-classes to request following data from the source to achieve infinite scrolling.
    internal func loadMoreData() {
        fatalError()
    }
    
    override func setupUI() {
        view.addSubview(vTopArea)
        vTopArea.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        view.insertSubview(vCollection, belowSubview: vTopArea)
        vCollection.snp.makeConstraints { make in
            make.top.equalTo(vTopArea.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        setupDataSource()
        refreshHeader.beginRefreshing()
    }
    
    // MARK: - Actions
    
    private var dataSource: UICollectionViewDiffableDataSource<CollectionSection, MangaItemDataModel>!
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: vCollection
        ) { collectionView, indexPath, itemIdentifier in
            self.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private let loaderModel = MangaItemDataModel()
    
    internal func setData(with model: MangaListDataModel) {
        mangaList = model.data
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, MangaItemDataModel>()
        snapshot.appendSections([.mangaList, .loader])
        snapshot.appendItems(model.data, toSection: .mangaList)
        if model.data.count < model.total {
            snapshot.appendItems([loaderModel], toSection: .loader)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    internal func updateData(with model: MangaListDataModel) {
        mangaList.append(contentsOf: model.data)
        var snapshot = self.dataSource.snapshot()
        snapshot.appendItems(model.data, toSection: .mangaList)
        if model.data.count == model.total {
            snapshot.deleteItems([loaderModel])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func scrollToTop() {
        if mangaList.count > 0 {
            vCollection.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    enum CollectionSection: Int {
        case mangaList
        case loader
    }
    
    private func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .mangaList:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "mangaCell",
                for: indexPath
            )
            (cell as! MangaListCollectionCell).update(mangaModel: mangaList[indexPath.row])
            return cell
        case .loader:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "loader",
                for: indexPath
            )
            return cell
        }
    }
}


// MARK: - UICollectionViewDelegate
extension MangaListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            fatalError()
        }
        let cellWidth = MDLayout.screenWidth - 2 * 10
        switch section {
        case .mangaList:
            return .init(width: cellWidth, height: 105)
        case .loader:
            return .init(width: cellWidth, height: 50)
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
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                self.loadMoreData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MDMangaDetailViewController(mangaModel: mangaList[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}