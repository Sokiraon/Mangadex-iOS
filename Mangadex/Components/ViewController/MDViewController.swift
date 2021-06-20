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
