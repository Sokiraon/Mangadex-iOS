//
//  MDStaredViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD

class MDStaredViewController: MDMangaListViewController {
    
    override func onHeaderRefresh() {
        MDHTTPManager.getInstance()
            .getUserFollowedMangas(params: [:]) { data in
                self.mangaList = data
                DispatchQueue.main.async {
                    self.refreshFooter.isHidden = false
                    self.vCollection.reloadData()
                    self.vCollection.mj_header?.endRefreshing()
                }
            } onError: {
                self.vCollection.mj_header?.endRefreshing()
                DispatchQueue.main.async {
                    self.alertForLogin()
                }
            }
    }
    
    override func onFooterRefresh() {
        MDHTTPManager.getInstance()
            .getUserFollowedMangas(
                params: [
                    "offset": self.mangaList.count,
                    "limit": 5
                ]
            ) { data in
                self.mangaList.append(contentsOf: data)
                DispatchQueue.main.async {
                    self.vCollection.reloadData()
                    self.vCollection.mj_footer?.endRefreshing()
                }
            } onError: {
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
