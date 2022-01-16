//
//  MDMangaDetailViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/1.
//

import Foundation
import UIKit
import Segmentio
import SwiftEventBus
import SwiftTheme

class MDMangaDetailViewController: MDViewController {
    
    // MARK: - tabs related
    private var tabVC: MDMangaDetailTabViewController!
    
    private lazy var tabOptions = SegmentioOptions(
        backgroundColor: .white,
        segmentPosition: .dynamic,
        scrollEnabled: false,
        indicatorOptions: SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 0.8,
            height: 2,
            color: .primaryColor
        ),
        horizontalSeparatorOptions: nil,
        verticalSeparatorOptions: nil,
        imageContentMode: .center,
        labelTextAlignment: .center,
        labelTextNumberOfLines: 1,
        segmentStates: SegmentioStates(
            defaultState: SegmentioState(
                titleFont: UIFont.systemFont(ofSize: 17),
                titleTextColor: .black
            ),
            selectedState: SegmentioState(
                titleFont: UIFont.systemFont(ofSize: 17),
                titleTextColor: .primaryColor
            ),
            highlightedState: SegmentioState(
                titleFont: UIFont.boldSystemFont(ofSize: 17),
                titleTextColor: .black
            )
        ),
        animationDuration: 0.2
    )
    
    private lazy var vTabs: Segmentio = {
        let view = Segmentio(frame: .zero)
        view.setup(content: [
            SegmentioItem(title: "kMangaDetailChapters".localized(), image: nil),
            SegmentioItem(title: "kMangaDetailInfo".localized(), image: nil),
        ], style: .onlyLabel, options: tabOptions)
        
        view.selectedSegmentioIndex = 0
        view.valueDidChange = { view, index in
            self.tabVC.shouldScrollPageAction(index)
        }
        
        return view
    }()
    
    // MARK: - actions
    private var lastReadChapter: String?
    
    private lazy var btnContinue: UIButton = {
        let button = UIButton(handler: {
            SwiftEventBus.post("openChapter", sender: self.lastReadChapter)
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
        tabVC.endPageScrollAction = { index in
            self.vTabs.selectedSegmentioIndex = index
        }
        
        self.mangaItem = mangaItem
        viewTitle = title
    }
    
    override func setupUI() {
        setupNavBar(preserveStatus: true)
        
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
        
        view.addSubview(vTabs)
        vTabs.snp.makeConstraints { make in
            make.top.equalTo(btnContinue.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        addChild(tabVC)
        view.addSubview(tabVC.view)
        tabVC.view.snp.makeConstraints { make in
            make.top.equalTo(vTabs.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func doOnAppear() {
        lastReadChapter = MDMangaProgressManager.retrieveProgress(forMangaId: mangaItem.id)
        if (lastReadChapter == nil) {
            btnContinue.setTitle("kMangaActionStartOver".localized(), for: .normal)
        } else {
            btnContinue.setTitle("kMangaActionContinue".localized(), for: .normal)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
