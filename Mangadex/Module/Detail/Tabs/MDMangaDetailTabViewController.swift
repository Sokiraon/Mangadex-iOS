//
//  MDMangaDetailTabViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import Pageboy
import Tabman
import XLPagerTabStrip

class MDMangaDetailTabViewController: ButtonBarPagerTabStripViewController {
    
    private var controllers = [MDViewController]()
    
    convenience init(mangaItem: MangaItem) {
        self.init()
        
        controllers.append(MDMangaDetailChapterViewController(mangaItem: mangaItem))
        controllers.append(MDMangaDetailInfoViewController(mangaItem: mangaItem))
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .themePrimary
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarItemTitleColor = .black2D2E2F
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        changeCurrentIndexProgressive = { oldCell,
                                          newCell,
                                          progressPercentage,
                                          changeCurrentIndex,
                                          animated in
            guard changeCurrentIndex == true else {
                return
            }
            
            if oldCell != nil {
                UIView.transition(
                    with: oldCell!.label, duration: 0.3, options: .transitionCrossDissolve
                ) {
                    oldCell?.label.textColor = .black2D2E2F
                }
            }
            if newCell != nil {
                UIView.transition(
                    with: newCell!.label!, duration: 0.3, options: .transitionCrossDissolve
                ) {
                    newCell?.label.textColor = .themePrimary
                }
            }
        }
        
        super.viewDidLoad()
    }
    
    override func viewControllers(
        for pagerTabStripController: PagerTabStripViewController
    ) -> [UIViewController] {
        controllers
    }
}
