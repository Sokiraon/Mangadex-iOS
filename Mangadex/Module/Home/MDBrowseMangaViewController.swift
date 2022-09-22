//
//  MDTrendViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import PromiseKit
import MJRefresh

class MDBrowseMangaViewController: MDMangaListViewController {
    
    override func onHeaderRefresh() {
        firstly {
            MDRequests.Manga.query(params: [
                "title": filterOptions.searchText
            ])
        }
            .done { items in
                self.mangaList = items
                DispatchQueue.main.async {
                    self.refreshFooter.isHidden = false
                    self.vCollection.reloadData()
                    self.vCollection.mj_header?.endRefreshing()
                }
            }
            .catch { error in
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                }
                self.vCollection.mj_header?.endRefreshing()
            }
    }
    
    override func onFooterRefresh() {
        firstly {
            MDRequests.Manga.query(params: [
                "title": filterOptions.searchText,
                "offset": self.mangaList.count,
            ])
        }
            .done { items in
                self.mangaList.append(contentsOf: items)
                DispatchQueue.main.async {
                    self.vCollection.reloadData()
                    self.vCollection.mj_footer?.endRefreshing()
                }
            }
            .catch { error in
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                }
                self.vCollection.mj_footer?.endRefreshing()
            }
    }
    
    override func filterOptionsDidChange() {
        firstly {
            MDRequests.Manga.query(params: [
                "title": filterOptions.searchText
            ])
        }.done { items in
            self.mangaList = items
            DispatchQueue.main.async {
                self.vCollection.reloadData()
            }
        }.catch { error in
            DispatchQueue.main.async {
                ProgressHUD.showError()
            }
        }
    }
}
