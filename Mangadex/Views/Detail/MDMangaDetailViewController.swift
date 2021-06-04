//
//  MDMangaDetailViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/1.
//

import Foundation
import UIKit

class MDMangaDetailViewController: UIViewController {
    static func initWithMangaCell(_ cell: MDMangaTableCell) -> MDMangaDetailViewController {
        return self.init()
    }
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
