//
//  MDViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/8.
//

import Foundation
import UIKit

protocol MDViewControllerDelegate {
    func willSetupUI() -> Void
    func setupUI() -> Void
    func didSetupUI() -> Void
}

class MDViewController: UIViewController, MDViewControllerDelegate {
    var viewTitle: String!
    var appBar: MDAppBar?
    var contentView: UIView?
    
    func willSetupUI() {}
    func setupUI() {}
    func didSetupUI() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        willSetupUI()
        setupUI()
        didSetupUI()
    }
    
    @objc func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
