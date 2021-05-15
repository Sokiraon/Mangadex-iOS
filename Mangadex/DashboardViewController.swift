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
    private var viewControllers = [UIViewController(), UIViewController()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        
        addBar(bar, dataSource: self, at: .top)
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
        let title = "Page \(index)"
        return TMBarItem(title: title)
    }
}
