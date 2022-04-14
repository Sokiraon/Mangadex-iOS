//
//  MDMangaDetailViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/1.
//

import Foundation
import UIKit
import SwiftEventBus
import SwiftTheme

class MDMangaDetailViewController: MDViewController {
    
    private var tabVC: MDMangaDetailTabViewController!
    
    private var lastViewedChapter: String?
    
    private lazy var btnContinue: UIButton = {
        let button = UIButton(handler: {
            SwiftEventBus.post("openChapter", sender: self.lastViewedChapter)
        }, titleColor: .white)
        
        button.theme_backgroundColor = UIColor.theme_primaryColor
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 15.0 / 17.0
        
        return button
    }()
    
    private lazy var btnFollow: UIButton = {
        let button = UIButton(handler: {
            
        }, title: "kMangaActionToFollow".localized(), titleColor: .white)
        
        button.theme_backgroundColor = UIColor.theme_primaryColor
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 15.0 / 17.0
        
        return button
    }()
    
    private var mangaItem: MangaItem!
    
    // MARK: - initialization
    convenience init(mangaItem: MangaItem, title: String) {
        self.init()
        
        tabVC = MDMangaDetailTabViewController(mangaItem: mangaItem)
        
        self.mangaItem = mangaItem
        self.viewTitle = title
    }
    
    override func setupUI() {
        setupNavBar()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.addSubview(btnContinue)
        btnContinue.snp.makeConstraints { make in
            make.top.equalTo(appBar!.snp.bottom).offset(15)
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(48)
        }
        btnContinue.layer.cornerRadius = 5
        
        view.addSubview(btnFollow)
        btnFollow.snp.makeConstraints { make in
            make.top.bottom.equalTo(btnContinue)
            make.right.equalToSuperview().inset(15)
            make.width.equalTo(100)
            make.left.equalTo(btnContinue.snp.right).offset(10)
        }
        btnFollow.layer.cornerRadius = 5
        btnFollow.isEnabled = false
        
        addChild(tabVC)
        view.addSubview(tabVC.view)
        tabVC.view.snp.makeConstraints { make in
            make.top.equalTo(btnContinue.snp.bottom).offset(15)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func doOnAppear() {
        lastViewedChapter = MDMangaProgressManager.retrieveProgress(forMangaId: mangaItem.id)
        if (lastViewedChapter == nil) {
            btnContinue.setTitle("kMangaActionStartOver".localized(), for: .normal)
        } else {
            btnContinue.setTitle("kMangaActionContinue".localized(), for: .normal)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
