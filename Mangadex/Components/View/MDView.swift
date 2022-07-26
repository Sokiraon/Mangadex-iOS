//
//  MDView.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/20.
//

import Foundation
import UIKit

/**
 Custom View that subclasses UIView and has a setupUI() method.
 
 This class is meant to be subclassed. Subclasses should override setupUI() method and make their own UIs.
 */
class MDView: UIView {
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {}
}
