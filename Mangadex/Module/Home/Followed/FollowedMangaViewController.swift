//
//  FollowedMangaViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit

class FollowedMangaViewController: MDPagerViewController {
    private let viewControllers = [
        FollowedLibraryViewController(),
        FollowedUpdatesViewController()
    ]
    
    private let titles = [
        "followed.bar.library.title".localized(),
        "followed.bar.updates.title".localized()
    ]

    override var pages: [MDPagerPage] {
        zip(titles, viewControllers).map { title, viewController in
            MDPagerPage(title: title, viewController: viewController)
        }
    }
}
