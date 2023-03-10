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
    
    override func fetchData() {
        MDRequests.Manga.query(params: ["title": filterOptions.searchText])
            .done { items in
                self.mangaList = items
                DispatchQueue.main.async {
                    self.vCollection.reloadData()
                }
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
        .done { items in
            self.mangaList.append(contentsOf: items)
            DispatchQueue.main.async {
                self.vCollection.reloadData()
            }
        }
        .catch { error in
            DispatchQueue.main.async {
                ProgressHUD.showError()
            }
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
