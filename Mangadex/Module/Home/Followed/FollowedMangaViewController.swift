//
//  FollowedMangaViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import MJRefresh
import Tabman
import Pageboy

class FollowedMangaViewController: TabmanViewController {
    private let viewControllers = [
        FollowedLibraryViewController(),
        FollowedUpdatesViewController()
    ]
    
    private let titles = [
        "followed.bar.library.title".localized(),
        "followed.bar.updates.title".localized()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        let bar = TMBar.ButtonBar()
        bar.backgroundView.style = .flat(color: .white)
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentInset = .init(top: 0, left: 0, bottom: 8, right: 0)
        bar.buttons.customize { button in
            button.tintColor = .darkGray808080
            button.selectedTintColor = .themeDark
        }
        bar.indicator.tintColor = .themeDark
        
        addBar(bar, dataSource: self, at: .top)
    }
}

extension FollowedMangaViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        .first
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        TMBarItem(title: titles[index])
    }
}
