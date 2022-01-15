//
//  MDMangaDetailTabViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import Pageboy
import Tabman

class MDMangaDetailTabViewController: PageboyViewController {
    
    var endPageScrollAction: ((Int) -> Void)?
    
    lazy var shouldScrollPageAction: (Int) -> Void = { index in
        self.scrollToPage(.at(index: index), animated: true)
    }
    
    private lazy var controllers = [
        MDMangaDetailChapterViewController(),
        MDMangaDetailInfoViewController(),
    ]
    
    convenience init(mangaItem: MangaItem) {
        self.init()
        
        (controllers[0] as? MDMangaDetailChapterViewController)?
            .updateWithMangaItem(mangaItem)
        (controllers[1] as? MDMangaDetailInfoViewController)?
            .updateWithMangaItem(mangaItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
}

extension MDMangaDetailTabViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        controllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        controllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        .first
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        if (endPageScrollAction != nil) {
            endPageScrollAction!(index)
        }
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, willScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didReloadWith currentViewController: UIViewController, currentPageIndex: PageboyViewController.PageIndex) {
        
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollTo position: CGPoint, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
    }
}
