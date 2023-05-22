//
//  BrowseMangaViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import PromiseKit
import MJRefresh

class BrowseMangaViewController: MangaListViewController {
    
    override func fetchData() {
        MDRequests.Manga.query(params: [
            "title": filterOptions.searchText,
            "limit": 20
        ])
            .done { model in
                self.setData(with: model)
            }
            .catch { error in
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                }
            }
            .finally {
                self.vCollection.mj_header?.endRefreshing()
            }
    }
    
    override func loadMoreData() {
        MDRequests.Manga.query(params: [
            "title": filterOptions.searchText,
            "offset": self.mangaList.count,
        ])
        .done { model in
            self.updateData(with: model)
        }
        .catch { error in
            DispatchQueue.main.async {
                ProgressHUD.showError()
            }
        }
    }
    
    // MARK: - Search Mechanism
    
    struct FilterOptions {
        var searchText = ""
    }
    
    private var filterOptions = FilterOptions()
    private lazy var vSearch = UISearchBar().apply { bar in
        bar.delegate = self
    }
    
    override func setupUI() {
        super.setupUI()
        
        vTopArea.layer.shadowColor = UIColor.primaryShadow
        vTopArea.layer.shadowRadius = 2
        vTopArea.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        vTopArea.addSubview(vSearch)
        vSearch.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
            make.height.equalTo(56)
        }
    }
    
    func filterOptionsDidChange() {
        firstly {
            MDRequests.Manga.query(params: [
                "title": filterOptions.searchText
            ])
        }.done { model in
            self.setData(with: model)
        }.catch { error in
            DispatchQueue.main.async {
                ProgressHUD.showError()
            }
        }
    }
    
    private var timer: Timer?
    
    private func scheduleFilterOptionChange() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            self.filterOptionsDidChange()
        })
    }
}

// MARK: - UICollectionView Delegate
extension BrowseMangaViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.vTopArea.layer.shadowOpacity = 0.5
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.vTopArea.layer.shadowOpacity = 0
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        vSearch.endEditing(true)
        vSearch.setShowsCancelButton(false, animated: true)
    }
}

// MARK: - UISearchBar Delegate
extension BrowseMangaViewController: UISearchBarDelegate {
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
