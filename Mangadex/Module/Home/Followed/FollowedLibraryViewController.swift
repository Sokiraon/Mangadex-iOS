//
//  FollowedLibraryViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/27.
//

import Foundation
import UIKit

class FollowedLibraryViewController: MangaListViewController {
    
    override func didSetupUI() {
        super.didSetupUI()
        if !UserManager.shared.userIsLoggedIn {
            refreshHeader.endRefreshing()
            alertForLogin()
        }
    }
    
    override func fetchData() {
        Requests.User.getFollowedMangas()
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
        Requests.User.getFollowedMangas(params: ["offset": self.mangaList.count])
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
        let vc = UIAlertController(
            title: "kWarning".localized(),
            message: "kLoginRequired".localized(),
            preferredStyle: .alert
        )
        vc.addAction(
            UIAlertAction(title: "kOk".localized(), style: .default) { action in
                MDRouter.goToLogin()
            }
        )
        vc.addAction(UIAlertAction(title: "kNo".localized(), style: .cancel))
        present(vc, animated: true)
    }
}
