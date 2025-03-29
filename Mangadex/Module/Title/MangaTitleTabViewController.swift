//
//  MangaTitleTabViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/27.
//

import Foundation
import UIKit
import Tabman
import Pageboy

class MangaTitleTabViewController: TabmanViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        bounces = false
        setupTabBar()
    }
    
    let chaptersTab = MangaTitleChaptersViewController()
    let infoTab = MangaTitleInfoViewController()
    let coversTab = MangaTitleCoversViewController()
    lazy var viewControllers = [chaptersTab, infoTab, coversTab]
    
    var mangaModel: MangaModel! {
        didSet {
            chaptersTab.mangaModel = mangaModel
            infoTab.mangaModel = mangaModel
            coversTab.mangaModel = mangaModel
        }
    }
    
    var currentScrollView: UIScrollView {
        if currentIndex == 0 {
            return chaptersTab.collectionView
        }
        else if currentIndex == 1 {
            return infoTab.scrollView
        }
        else {
            return coversTab.collectionView
        }
    }
    
    private func setupTabBar() {
        dataSource = self
        
        let bar = TMBar.ButtonBar()
        bar.backgroundView.style = .flat(color: .white)
        bar.layout.transitionStyle = .snap
        bar.layout.contentInset = .cssStyle(4, 20)
        bar.buttons.customize { button in
            button.tintColor = .darkGray808080
            button.selectedTintColor = .themeDark
            button.contentInset = .cssStyle(8, 2)
        }
        bar.indicator.tintColor = .themeDark
        
        addBar(bar, dataSource: self, at: .top)
    }
}

extension MangaTitleTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        viewControllers.count
    }
    
    func viewController(for pageboyViewController: Pageboy.PageboyViewController,
                        at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index]
    }
    
    func defaultPage(
        for pageboyViewController: Pageboy.PageboyViewController
    ) -> Pageboy.PageboyViewController.Page? {
        nil
    }
    
    func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
        let item = TMBarItem(title: "")
        switch index {
        case 0:
            item.title = "manga.detail.tab.chapters".localized()
        case 1:
            item.title = "manga.detail.tab.info".localized()
        case 2:
            item.title = "manga.detail.tab.covers".localized()
        default:
            break
        }
        return item
    }
}
