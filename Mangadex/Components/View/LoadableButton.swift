//
//  LoadableButton.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/28.
//

import Foundation
import UIKit

class LoadableButton: UIButton {
    
    let spinner = UIActivityIndicatorView()
    
    var isLoading = false {
        didSet {
            if isLoading {
                spinner.startAnimating()
                imageView?.alpha = 0
                titleLabel?.alpha = 0
            } else {
                spinner.stopAnimating()
                imageView?.alpha = 1
                titleLabel?.alpha = 1
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(spinner)
        spinner.color = .darkerGray565656
        spinner.hidesWhenStopped = true
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
