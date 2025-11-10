//
//  FollowedLibraryViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/27.
//

import Foundation
import UIKit

class FollowedLibraryViewController: MangaListViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { @MainActor in
            let isLoggedIn = await UserManager.shared.userIsLoggedIn
            if !isLoggedIn {
                await refreshHeader.endRefreshing()
                alertForLogin()
            }
        }
    }
    
    override func fetchData() async {
        do {
            let model = try await Requests.User.getFollowedMangas()
            self.setData(with: model)
        } catch {
            self.alertForLogin()
        }
        await self.vCollection.mj_header?.endRefreshing()
    }
    
    override func loadMoreData() async {
        do {
            let model = try await Requests.User
                .getFollowedMangas(params: ["offset": self.mangaList.count])
            self.updateData(with: model)
        } catch {
            self.alertForLogin()
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
