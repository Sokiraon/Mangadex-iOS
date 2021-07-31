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

class MDHomeViewController: TabmanViewController {
    private lazy var viewControllers = [
        MDTrendViewController(),
        MDStaredViewController(),
        MDAccountViewController()
    ]
    private lazy var tabBarItems = [
        TMBarItem(title: "kDashboardTabTrend".localized(),
                  image: UIImage(named: "baseline_trending_up_black_24pt")!),
        TMBarItem(title: "kDashboardTabStared".localized(),
                  image: UIImage(named: "baseline_star_black_24pt")!),
        TMBarItem(title: "kDashboardTabAccount".localized(),
                  image: UIImage(named: "baseline_person_black_24pt")!)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        let bar = TMBar.TabBar()
        bar.layout.transitionStyle = .snap
        bar.buttons.customize { button in
        }
        
        addBar(bar.systemBar(), dataSource: self, at: .bottom)
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
