//
//  MDMangaDetailViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/1.
//

import Foundation
import UIKit

class MDMangaDetailViewController: MDViewController {
    
    private var tabVC: MDMangaDetailTabViewController!
    
    // MARK: - initialization
    static func initWithMangaItem(_ item: MangaItem, title: String) -> MDMangaDetailViewController {
        let vc = self.init()
        vc.tabVC = MDMangaDetailTabViewController.initWithMangaItem(item)
        vc.viewTitle = title
        return vc
    }
    
    override func setupUI() {
        setupNavBar(backgroundColor: .white, preserveStatus: true)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.addSubview(appBar!)
        appBar!.snp.makeConstraints { make in
            make.top.equalTo(MDLayout.safeAreaInsets(true).top)
            make.left.right.equalToSuperview()
        }
        
        addChild(tabVC)
        view.addSubview(tabVC.view)
        tabVC.view.snp.makeConstraints { make in
            make.top.equalTo(self.appBar!.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
    }
}
