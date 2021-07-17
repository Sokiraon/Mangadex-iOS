//
//  MDMangaDetailTabViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import Pageboy
import Tabman

class MDMangaDetailTabViewController: TabmanViewController {
    
    private lazy var controllers = [
        MDMangaDetailChapterViewController(),
        MDMangaDetailInfoViewController()
    ]
    
    static func initWithMangaItem(_ item: MangaItem) -> MDMangaDetailTabViewController {
        let vc = MDMangaDetailTabViewController()
        (vc.controllers[0] as? MDMangaDetailChapterViewController)?.updateWithMangaItem(item)
        (vc.controllers[1] as? MDMangaDetailInfoViewController)?.updateWithMangaItem(item)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        let bar = TMBar.ButtonBar()
        bar.backgroundView.style = .clear
        bar.layout.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        bar.layout.contentMode = .fit
        addBar(bar, dataSource: self, at: .top)
    }
}

extension MDMangaDetailTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        controllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        controllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        nil
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "kMangaDetailChapters".localized())
        default:
            return TMBarItem(title: "kMangaDetailInfo".localized())
        }
    }
}
