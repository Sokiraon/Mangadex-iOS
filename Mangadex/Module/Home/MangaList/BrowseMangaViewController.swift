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
        Requests.Manga.query(params: [
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
        Requests.Manga.query(params: [
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
}
