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
    struct FilterOptions {
        var searchText: String = ""
    }
    
    internal var allowFilter = true
    internal var filterOptions = FilterOptions()
    
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
    
    internal lazy var vSearch = UISearchBar().apply { view in
        view.delegate = self
    }
    
    internal func filterOptionsDidChange() {}
    
    private let vTopBar = UIView(backgroundColor: .white).apply { view in
        view.layer.shadowColor = UIColor.black2D2E2F.cgColor
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    override func setupUI() {
        if allowFilter {
            view.addSubview(vTopBar)
            vTopBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
            }
            
            vTopBar.addSubview(vSearch)
            vSearch.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
                make.height.equalTo(56)
            }
            
            view.insertSubview(vCollection, belowSubview: vTopBar)
            vCollection.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(MDLayout.safeInsetTop + 56)
                make.left.right.bottom.equalToSuperview()
            }
        } else {
            view.addSubview(vCollection)
            vCollection.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
                make.left.right.bottom.equalToSuperview()
            }
        }
    }
    
    override func didSetupUI() {
        vCollection.mj_header = refreshHeader
        refreshHeader.beginRefreshing()
    }
    
    internal var timer: Timer?
    
    private func scheduleFilterOptionChange() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            self.filterOptionsDidChange()
        })
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
        guard !mangaList.isEmpty else { return }
        
        if section == .loader {
            loadMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MDMangaDetailViewController(mangaModel: mangaList[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.vTopBar.layer.shadowOpacity = 0.5
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.vTopBar.layer.shadowOpacity = 0
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        vSearch.endEditing(true)
        vSearch.setShowsCancelButton(false, animated: true)
    }
}

// MARK: - UISearchBar Delegate Methods
extension MDMangaListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterOptions.searchText = searchText
        scheduleFilterOptionChange()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
