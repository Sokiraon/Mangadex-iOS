//
//  MDViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/8.
//

import Foundation
import UIKit

class MDViewController: UIViewController {
    var viewTitle: String!
    var appBar: MDAppBar?

    ///
    /// Called at viewDidLoad, before setupUI().
    /// Should be used for preparing data that is needed by UI components.
    /// However, do notice that this will only be called once in the lifecycle (compared to initOnAppear).
    func willSetupUI() {}

    ///
    /// Called at viewDidLoad, after willSetupUI().
    /// Should be used for adding subviews and configuring their layout.
    func setupUI() {}

    ///
    /// Called at viewDidLoad, after setupUI().
    func didSetupUI() {}

    ///
    /// Called at viewWillAppear, should be used for initializing data or organizing views for animation.
    /// Do notice that this will be called every time the view comes into foreground, so you may want to avoid complex actions.
    func doOnAppear() {}
    
    ///
    /// Called when vc is aboout to leave the page (i.e. user taps back button).
    /// You may use this func to save progress.
    func willLeavePage() {}

    ///
    /// Used for setting up top navigation bar.
    /// - Parameters:
    ///   - backgroundColor: color for bar background, this will be used for generating color for bar text by **reversing**
    ///   - preserveStatus: **true** to reserve space for system status bar, **false** for hiding it
    func setupNavBar(backgroundColor: UIColor, preserveStatus: Bool) {
        appBar = MDAppBar.initWithTitle(viewTitle, backgroundColor: backgroundColor)
        appBar?.btnBack.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        view.addSubview(appBar!)
        appBar!.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth)
            make.top.equalTo(MDLayout.safeAreaInsets(preserveStatus).top)
            if (MDLayout.isNotchScreen) {
                make.height.equalTo(MDLayout.safeAreaInsets(!preserveStatus).top + 50)
            } else {
                make.height.equalTo(50)
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doOnAppear()
    }
    
    @objc private func didTapBack() {
        willLeavePage()
        navigationController?.popViewController(animated: true)
    }
}
