//
//  BaseViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/8.
//

import Foundation
import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    ///
    /// Called at viewDidLoad, before setupUI().
    ///
    /// Should be used for preparing data that is needed by UI components.
    /// However, do notice that this will only be called once in the lifecycle (compared to initOnAppear).
    internal func willSetupUI() {}
    
    ///
    /// Called at viewDidLoad, after willSetupUI().
    ///
    /// Should be used for adding subviews and configuring their layout.
    internal func setupUI() {}
    
    ///
    /// Called at viewDidLoad, after setupUI().
    internal func didSetupUI() {}
    
    internal var statusBarStyle = UIStatusBarStyle.default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
    
    internal var isStatusBarHidden = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        isStatusBarHidden
    }
    
    internal lazy var AppBarHeight = MDLayout.safeInsetTop + 44
    
    /// Default AppBar of the viewController. Loaded on-demand.
    internal lazy var appBar = AppBar().apply { _ in
        self.statusBarStyle = .lightContent
    }
    
    ///
    /// Used for setting up top navigation bar.
    internal func setupNavBar(title: String? = nil,
                              backgroundColor: UIColor = .themePrimary,
                              style: AppBar.Style = .filled) {
        if title != nil {
            appBar.title = title
        }
        if style == .blur {
            statusBarStyle = .darkContent
            appBar.backgroundColor = .clear
            appBar.lblTitle.textColor = .black
            appBar.btnBack.configuration?.baseForegroundColor = .black
            
            appBar.insertSubview(appBar.blurView, at: 0)
            appBar.blurView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            appBar.backgroundColor = backgroundColor
            statusBarStyle = .lightContent
        }
        
        view.addSubview(appBar)
        appBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.height.equalTo(AppBarHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = true
        
        willSetupUI()
        setupUI()
        didSetupUI()
    }
    
#if DEBUG
    // For injectionIII
    @objc func injected() {
        viewDidLoad()
    }
#endif
}
