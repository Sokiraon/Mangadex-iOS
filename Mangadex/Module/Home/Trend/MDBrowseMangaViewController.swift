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

class MDBrowseMangaViewController: MDMangaListViewController {
    
    override func onHeaderRefresh() {
        MDHTTPManager.getInstance()
            .getMangaListWithParams([:]) { data in
                self.mangaList = data
                DispatchQueue.main.async {
                    self.refreshFooter.isHidden = false
                    self.vCollection.reloadData()
                    self.vCollection.mj_header?.endRefreshing()
                }
            } onError: {
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                }
                self.vCollection.mj_header?.endRefreshing()
            }
    }
    
    override func onFooterRefresh() {
        MDHTTPManager.getInstance()
            .getMangaListWithParams([
                "offset": self.mangaList.count,
                "limit": 5
            ]) { data in
                self.mangaList.append(contentsOf: data)
                DispatchQueue.main.async {
                    self.vCollection.reloadData()
                    self.vCollection.mj_footer?.endRefreshing()
                }
            } onError: {
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                }
                self.vCollection.mj_footer?.endRefreshing()
            }
    }
}
