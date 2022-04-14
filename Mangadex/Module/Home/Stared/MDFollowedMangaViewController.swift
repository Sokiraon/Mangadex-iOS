//
//  MDStaredViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import PromiseKit

class MDFollowedMangaViewController: MDMangaListViewController {
    
    override func onHeaderRefresh() {
        firstly {
            MDRequests.User.getFollowedMangas(params: [:])
        }.done { data in
            self.mangaList = data
            DispatchQueue.main.async {
                self.refreshFooter.isHidden = false
                self.vCollection.reloadData()
                self.vCollection.mj_header?.endRefreshing()
            }
        }.catch { error in
            self.vCollection.mj_header?.endRefreshing()
            DispatchQueue.main.async {
                self.alertForLogin()
            }
        }
    }
    
    override func onFooterRefresh() {
        firstly {
            MDRequests.User.getFollowedMangas(params: ["offset": self.mangaList.count,
                                                       "limit": 5])
        }.done { data in
            self.mangaList.append(contentsOf: data)
            DispatchQueue.main.async {
                self.vCollection.reloadData()
                self.vCollection.mj_footer?.endRefreshing()
            }
        }.catch { error in
            self.vCollection.mj_footer?.endRefreshing()
            DispatchQueue.main.async {
                self.alertForLogin()
            }
        }
    }
    
    private func alertForLogin() {
        let alert = UIAlertController.initWithTitle(
            "kWarning".localized(),
            message: "kLoginRequired".localized(), style: .alert,
            actions:
                AlertViewAction(title: "kOk".localized(), style: .default) { action in
                    let vc = MDPreLoginViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                },
            AlertViewAction(title: "kNo".localized(), style: .default, handler: nil)
        )
        present(alert, animated: true)
    }
}
