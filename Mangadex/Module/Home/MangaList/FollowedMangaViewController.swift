//
//  FollowedMangaViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import PromiseKit
import MJRefresh

class FollowedMangaViewController: MangaListViewController {
    
    override func setupUI() {
        super.setupUI()
        
        vTopArea.snp.makeConstraints { make in
            make.height.equalTo(MDLayout.safeInsetTop)
        }
    }
    
    override func didSetupUI() {
        super.didSetupUI()
        if !UserManager.shared.userIsLoggedIn {
            refreshHeader.endRefreshing()
            alertForLogin()
        }
    }
    
    override func fetchData() {
        MDRequests.User.getFollowedMangas()
            .done { model in
                self.setData(with: model)
            }
            .catch { error in
                DispatchQueue.main.async {
                    self.alertForLogin()
                }
            }
            .finally {
                self.vCollection.mj_header?.endRefreshing()
            }
    }
    
    override func loadMoreData() {
        MDRequests.User.getFollowedMangas(params: ["offset": self.mangaList.count])
            .done { model in
                self.updateData(with: model)
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
