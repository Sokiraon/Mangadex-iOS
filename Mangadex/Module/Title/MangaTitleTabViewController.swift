//
//  MangaTitleTabViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/27.
//

import Foundation
import UIKit

class MangaTitleTabViewController: MDPagerViewController {
    let chaptersTab = MangaTitleChaptersViewController()
    let infoTab = MangaTitleInfoViewController()
    let coversTab = MangaTitleCoversViewController()
    lazy var viewControllers = [chaptersTab, infoTab, coversTab]
    private lazy var titles = [
        "manga.detail.tab.chapters".localized(),
        "manga.detail.tab.info".localized(),
        "manga.detail.tab.covers".localized()
    ]

    override var pages: [MDPagerPage] {
        zip(titles, viewControllers).map { title, viewController in
            MDPagerPage(title: title, viewController: viewController)
        }
    }

    override var pageBounces: Bool {
        false
    }

    override var overlaysTabBarOnPageContent: Bool {
        true
    }
    
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
            return infoTab.collectionView
        }
        else {
            return coversTab.collectionView
        }
    }
}
