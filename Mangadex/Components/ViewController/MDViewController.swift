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
    
    func willSetupUI() {}
    func setupUI() {}
    func didSetupUI() {}
    func initDataOnAppear() {}
    
    func setupNavBar(backgroundColor: UIColor, preserveStatus: Bool) {
        appBar = MDAppBar.initWithTitle(self.viewTitle, backgroundColor: backgroundColor)
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
        willSetupUI()
        setupUI()
        didSetupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initDataOnAppear()
    }
    
    @objc func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
