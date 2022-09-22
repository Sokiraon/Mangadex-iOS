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
import PromiseKit
import ProgressHUD

class MDMangaDetailViewController: MDViewController {
    
    private var tabVC: MDMangaDetailTabViewController!
    
    private var lastViewedChapter: String?
    
    private lazy var btnContinue = UIButton(
        type: .custom,
        primaryAction: UIAction { _ in
            SwiftEventBus.post("openChapter", sender: self.lastViewedChapter)
        }
    ).apply { button in
        button.theme_backgroundColor = UIColor.theme_primaryColor
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 15.0 / 17.0
        button.setTitleColor(.white, for: .normal)
    }
    
    private var btnFollowConfFollowed: UIButton.Configuration!
    private var btnFollowConfUnFollowed: UIButton.Configuration!
    
    private lazy var btnFollow = UIButton(
        type: .custom,
        primaryAction: UIAction { _ in
            self.changeFollowStatus()
        }
    ).apply { button in
        var btnConfCommon = UIButton.Configuration.gray()
        btnConfCommon.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        btnConfCommon.imagePadding = 4
        
        btnFollowConfFollowed = btnConfCommon
        btnFollowConfFollowed.title = "kMangaActionFollowed".localized()
        btnFollowConfFollowed.image = .init(named: "icon_bookmark")
        btnFollowConfFollowed.baseForegroundColor = .black2D2E2F
        
        btnFollowConfUnFollowed = btnConfCommon
        btnFollowConfUnFollowed.title = "kMangaActionToFollow".localized()
        btnFollowConfUnFollowed.image = .init(named: "icon_bookmark_border")
        btnFollowConfUnFollowed.baseForegroundColor = .white
        btnFollowConfUnFollowed.baseBackgroundColor = .cerulean400
        
        button.configuration = btnFollowConfUnFollowed
    }
    
    private var mangaItem: MangaItem!
    
    private var isMangaFollowed = false
    
    // MARK: - Actions
    func changeFollowStatus() {
        ProgressHUD.show()
        firstly {
            if isMangaFollowed {
                return MDRequests.Manga.unFollow(mangaId: mangaItem.id)
            } else {
                return MDRequests.Manga.follow(mangaId: mangaItem.id)
            }
        }.done { successful in
            if successful {
                self.isMangaFollowed = !self.isMangaFollowed
                if self.isMangaFollowed {
                    self.btnFollow.configuration = self.btnFollowConfFollowed
                } else {
                    self.btnFollow.configuration = self.btnFollowConfUnFollowed
                }
                ProgressHUD.dismiss()
            }
        }
    }
    
    // MARK: - initialization
    convenience init(mangaItem: MangaItem) {
        self.init()
        
        self.tabVC = MDMangaDetailTabViewController(mangaItem: mangaItem)
        self.mangaItem = mangaItem
        self.viewTitle = mangaItem.title
    }
    
    override func setupUI() {
        setupNavBar()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.addSubview(btnContinue)
        btnContinue.snp.makeConstraints { make in
            make.top.equalTo(appBar!.snp.bottom).offset(15)
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.width.greaterThanOrEqualToSuperview().dividedBy(2)
        }
        btnContinue.layer.cornerRadius = 5
        
        view.addSubview(btnFollow)
        btnFollow.snp.makeConstraints { make in
            make.top.bottom.equalTo(btnContinue)
            make.right.equalToSuperview().inset(15)
            make.left.equalTo(btnContinue.snp.right).offset(10)
        }
        btnFollow.layer.cornerRadius = 5
        
        addChild(tabVC)
        view.addSubview(tabVC.view)
        tabVC.view.snp.makeConstraints { make in
            make.top.equalTo(btnContinue.snp.bottom).offset(15)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        ProgressHUD.show()
        firstly {
            MDRequests.User.checkIfFollowsManga(mangaId: mangaItem.id)
        }.done { followed in
            self.isMangaFollowed = followed
            self.btnFollow.isUserInteractionEnabled = true
            if followed {
                self.btnFollow.configuration = self.btnFollowConfFollowed
            } else {
                self.btnFollow.configuration = self.btnFollowConfUnFollowed
            }
            ProgressHUD.dismiss()
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
