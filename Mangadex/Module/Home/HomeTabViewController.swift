//
//  HomeTabViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import UIKit
import Localize_Swift

class HomeTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabs.append(
            UITab(
                title: "kHomeTabBrowse".localized(),
                image: UIImage(systemName: "books.vertical.fill"),
                identifier: "Browse"
            ) { tab in
                return BrowseMangaViewController()
            }
        )
        
        tabs.append(
            UITab(
                title: "kHomeTabFollowed".localized(),
                image: UIImage(systemName: "bookmark.fill"),
                identifier: "Followed"
            ) { tab in
                return FollowedMangaViewController()
            }
        )
        
        tabs.append(
            UITab(
                title: "kHomeTabAccount".localized(),
                image: UIImage(systemName: "person.fill"),
                identifier: "Account"
            ) { tab in
                return AccountViewController()
            }
        )
        
        tabs.append(
            UISearchTab { tab in
                return SearchViewController()
            }
        )
    }
}
