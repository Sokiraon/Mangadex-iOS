//
//  MDTrendViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import SkeletonView
import PromiseKit

class MDBrowseMangaViewController: MDMangaListViewController {
    
    override func onHeaderRefresh() {
        firstly {
            MDRequests.Manga.query()
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
                "offset": self.mangaList.count,
                "limit": 5
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
}
