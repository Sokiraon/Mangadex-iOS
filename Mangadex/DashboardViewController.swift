//
//  DashboardViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import UIKit
import Tabman
import Pageboy

class DashboardViewController: TabmanViewController {
    private var viewControllers: [UIViewController]!
    private var tabBarItems = [
        TMBarItem(title: "Trend", image: UIImage(named: "baseline_trending_up_black_24pt")!),
        TMBarItem(title: "Stared", image: UIImage(named: "baseline_star_black_24pt")!),
        TMBarItem(title: "Account", image: UIImage(named: "baseline_person_black_24pt")!)
    ]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewControllers = [MDTrendViewController(), MDStaredViewController(), MDAccountViewController()]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewControllers = [MDTrendViewController(), MDStaredViewController(), MDAccountViewController()]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        let bar = TMBar.TabBar()
        bar.layout.transitionStyle = .snap
        
        addBar(bar.systemBar(), dataSource: self, at: .bottom)
    }
}

extension DashboardViewController: PageboyViewControllerDataSource, TMBarDataSource {
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
