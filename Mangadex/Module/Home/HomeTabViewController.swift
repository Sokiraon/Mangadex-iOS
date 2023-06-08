//
//  HomeTabViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import UIKit
import Localize_Swift
import Tabman
import Pageboy

class HomeTabViewController: TabmanViewController {
    
    private var viewControllers = [
        BrowseMangaViewController(),
        FollowedMangaViewController(),
        SearchViewController(),
        AccountViewController()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        dataSource = self
        isScrollEnabled = false
        
        let bar = TMBar.TabBar()
        bar.layout.contentInset = .bottom(.rectScreenOnly(5))
        bar.buttons.customize { button in
            button.font = .systemFont(ofSize: 12)
            button.imageViewSize = .init(width: 28, height: 28)
        }
        
        addBar(bar.systemBar(), dataSource: self, at: .bottom)
    }
}

extension HomeTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        nil
    }
    
    func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
        let item = TMBarItem(title: "")
        switch index {
        case 0:
            item.title = "kHomeTabBrowse".localized()
            item.image = .init(systemName: "books.vertical.fill")
            break
        case 1:
            item.title = "kHomeTabFollowed".localized()
            item.image = .init(systemName: "bookmark.fill")
            break
        case 2:
            item.title = "kHomeTabSearch".localized()
            item.image = .init(systemName: "magnifyingglass")
            break
        case 3:
            item.title = "kHomeTabAccount".localized()
            item.image = .init(systemName: "person.fill")
            break
        default:
            break
        }
        return item
    }
}
