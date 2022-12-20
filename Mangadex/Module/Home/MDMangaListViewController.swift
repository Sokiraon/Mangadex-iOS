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

fileprivate let cellMargin = 10.0

class MDMangaListViewController: MDViewController {
    struct FilterOptions {
        var searchText: String = ""
    }
    
    internal var allowFilter = true
    internal var filterOptions = FilterOptions()
    
    internal var mangaList = [MDMangaItemDataModel]()
    
    internal lazy var vCollection: UICollectionView = {
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
        view.contentInset = .cssStyle(5, cellMargin)
        view.backgroundColor = .clear
        return view
    }()
    
    internal lazy var refreshHeader = MJRefreshNormalHeader {
        self.onHeaderRefresh()
    }
    internal lazy var refreshFooter = MJRefreshBackNormalFooter {
        self.onFooterRefresh()
    }
    
    internal lazy var vSearch = UISearchBar().apply { view in
        view.delegate = self
    }
    
    internal func onHeaderRefresh() {}
    internal func onFooterRefresh() {}
    
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
        vCollection.mj_footer = refreshFooter
        vCollection.mj_footer?.isHidden = true
        
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
        (cell as! MDMangaListCollectionCell).update(mangaModel: mangaList[indexPath.row])
        return cell
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
