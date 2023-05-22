//
//  MDHomeTabViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import UIKit
import Localize_Swift
import SwiftTheme

class MDHomeTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(didChangeTheme),
//            name: NSNotification.Name(rawValue: ThemeUpdateNotification),
//            object: nil
//        )
    }
    
    private func setupTabBar() {
        delegate = self
        
        let browse = BrowseMangaViewController()
        browse.tabBarItem.title = "kHomeTabBrowse".localized()
        browse.tabBarItem.image = .init(systemName: "books.vertical.fill")
        
        let followed = FollowedMangaViewController()
        followed.tabBarItem.title = "kHomeTabFollowed".localized()
        followed.tabBarItem.image = .init(systemName: "bookmark.fill")
        
        let account = AccountViewController()
        account.tabBarItem.title = "kHomeTabAccount".localized()
        account.tabBarItem.image = .init(systemName: "person.fill")
        
        viewControllers = [browse, followed, account]
        previousViewController = browse
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Leave some space above UITabBarButton
        tabBar.frame.size.height += 4
        tabBar.frame.origin.y -= 4
    }
    
    // MARK: - UITabBarDelegate Methods
    
    private var previousViewController: UIViewController!
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        if let vc = viewController as? MangaListViewController,
           viewController == previousViewController {
            vc.scrollToTop()
        }
        previousViewController = viewController
    }
}
