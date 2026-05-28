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
    
    internal var mangaList = [MangaModel]()

    internal var usesSystemNavigationBar: Bool {
        true
    }

    internal var navigationBarTitle: String? {
        nil
    }

    private lazy var collectionLayout = UICollectionViewFlowLayout().apply { layout in
        layout.estimatedItemSize = CGSize(
            width: MDLayout.screenWidth - 32,
            height: 105
        )
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 12
    }
    
    internal lazy var vCollection = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionLayout
    ).apply { view in
        view.delegate = self
        view.register(MangaListCollectionCell.self, forCellWithReuseIdentifier: "mangaCell")
        view.register(CollectionLoaderCell.self, forCellWithReuseIdentifier: "loader")
        view.contentInset = .cssStyle(16)
        refreshHeader.ignoredScrollViewContentInsetTop = 16
        view.mj_header = refreshHeader
    }
    
    internal lazy var refreshHeader = MJRefreshNormalHeader {
        Task { @MainActor in
            await self.fetchData()
        }
    }
    
    /// Called when user pulls the refresh header.
    /// Must be overrideen by sub-classes to request initial data from the source.
    internal func fetchData() async {
        fatalError()
    }
    /// Called when the loader view enters screen.
    /// Must be overridden by sub-classes to request following data from the source to achieve infinite scrolling.
    internal func loadMoreData() async {
        fatalError()
    }
    
    override func setupUI() {
        if usesSystemNavigationBar {
            makeNavigationBar(title: navigationBarTitle)
        }

        view.addSubview(vCollection)
        vCollection.snp.makeConstraints { make in
            if usesSystemNavigationBar {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.bottom.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(
            !usesSystemNavigationBar,
            animated: animated
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard usesSystemNavigationBar else { return }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didSetupUI() {
        setupDataSource()
        refreshHeader.beginRefreshing()
    }
    
    // MARK: - Actions
    
    private var dataSource: UICollectionViewDiffableDataSource<CollectionSection, String>!
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: vCollection
        ) { collectionView, indexPath, itemIdentifier in
            self.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private let loaderIdentifer = "loader"
    
    internal func setData(with model: MangaCollection) {
        mangaList = model.data
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, String>()
        snapshot.appendSections([.mangaList, .loader])
        snapshot.appendItems(model.data.map { $0.id }, toSection: .mangaList)
        if model.data.count < model.total {
            snapshot.appendItems([loaderIdentifer], toSection: .loader)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    internal func updateData(with model: MangaCollection) {
        mangaList.append(contentsOf: model.data)
        var snapshot = self.dataSource.snapshot()
        snapshot.appendItems(model.data.map { $0.id }, toSection: .mangaList)
        if mangaList.count == model.total {
            snapshot.deleteItems([loaderIdentifer])
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
            (cell as! MangaListCollectionCell).setContent(mangaModel: mangaList[indexPath.row])
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
extension MangaListViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return
        }
        if section == .loader {
            Task { @MainActor in
                try await Task.sleep(for: .seconds(1))
                await self.loadMoreData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MangaTitleViewController(mangaModel: mangaList[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
