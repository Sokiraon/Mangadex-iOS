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
import MJRefresh

class MDFollowedMangaViewController: MDMangaListViewController {
    
    override func setupUI() {
        allowFilter = false
        super.setupUI()
    }
    
    override func didSetupUI() {
        super.didSetupUI()
        if !MDUserManager.getInstance().userIsLoggedIn {
            refreshHeader.endRefreshing()
            alertForLogin()
        }
    }
    
    override func fetchData() {
        MDRequests.User.getFollowedMangas()
            .done { model in
                self.mangaList = model.data
                self.mangaTotal = model.total
                DispatchQueue.main.async {
                    self.vCollection.reloadData()
                    self.vCollection.mj_header?.endRefreshing()
                }
            }
            .catch { error in
                self.vCollection.mj_header?.endRefreshing()
                DispatchQueue.main.async {
                    self.alertForLogin()
                }
            }
    }
    
    override func loadMoreData() {
        MDRequests.User.getFollowedMangas(params: ["offset": self.mangaList.count])
            .done { model in
                self.mangaList.append(contentsOf: model.data)
                self.mangaTotal = model.total
                DispatchQueue.main.async {
                    self.vCollection.reloadData()
                }
            }
            .catch { error in
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
                    MDRouter.goToLogin()
                },
            AlertViewAction(title: "kNo".localized(), style: .default, handler: nil)
        )
        present(alert, animated: true)
    }
}
