//
//  MDHomeTabViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import UIKit
import Tabman
import Pageboy
import Localize_Swift
import SwiftTheme

class MDHomeTabViewController: TabmanViewController {
    private lazy var viewControllers = [
        MDBrowseMangaViewController(),
        MDFollowedMangaViewController(),
        MDAccountViewController()
    ]
    private lazy var tabBarItems = [
        TMBarItem(
            title: "kHomeTabBrowse".localized(),
            image: .init(systemName: "books.vertical.fill")!
        ),
        TMBarItem(
            title: "kHomeTabFollowed".localized(),
            image: .init(systemName: "bookmark.fill")!
        ),
        TMBarItem(
            title: "kHomeTabAccount".localized(),
            image: .init(systemName: "person.fill")!
        ),
    ]
    
    private let bar = TMBar.TabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        bar.layout.transitionStyle = .snap
        bar.layout.contentInset = .bottom(.rectScreenOnlyValue(5))
        bar.buttons.customize { button in
            button.font = .systemFont(ofSize: 13)
            button.selectedTintColor = .primaryColor
            button.imageViewSize = CGSize(width: 32, height: 32)
        }
        
        addBar(bar.systemBar(), dataSource: self, at: .bottom)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeTheme),
            name: NSNotification.Name(rawValue: ThemeUpdateNotification),
            object: nil
        )
    }
    
    @objc func didChangeTheme() {
        bar.buttons.customize { button in
            button.selectedTintColor = .primaryColor
        }
    }
}

extension MDHomeTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return tabBarItems[index]
    }
}
