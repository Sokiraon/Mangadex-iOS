//
//  DashboardViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import UIKit
import Tabman
import Pageboy
import Localize_Swift
import SwiftTheme

class MDHomeViewController: TabmanViewController {
    private lazy var viewControllers = [
        MDTrendViewController(),
        MDStaredViewController(),
        MDAccountViewController()
    ]
    private lazy var tabBarItems = [
        TMBarItem(title: "kDashboardTabTrend".localized(),
                  image: UIImage(named: "icon_trending_up")!),
        TMBarItem(title: "kDashboardTabFollowed".localized(),
                  image: UIImage(named: "icon_bookmark")!),
        TMBarItem(title: "kDashboardTabAccount".localized(),
                  image: UIImage(named: "icon_person")!)
    ]
    
    private let bar = TMBar.TabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        bar.layout.transitionStyle = .snap
        bar.buttons.customize { button in
            button.selectedTintColor = .currentTintColor
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
            button.selectedTintColor = .currentTintColor
        }
    }
}

extension MDHomeViewController: PageboyViewControllerDataSource, TMBarDataSource {
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
