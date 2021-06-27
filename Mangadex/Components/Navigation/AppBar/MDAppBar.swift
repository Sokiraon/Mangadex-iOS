//
//  MDAppBar.swift
//  Mangadex
//
//  Created by edz on 2021/6/8.
//

import Foundation
import UIKit

class MDAppBar: UIView {
    lazy var btnBack: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "baseline_arrow_back_black_36pt"), for: .normal)
        button.contentMode = .scaleToFill
        return button
    }()
    
    lazy var lblTitle: UILabel = UILabel.initWithText("", ofFontWeight: .regular, andSize: 20)
    
    static func initWithTitle(_ title: String, backgroundColor: UIColor) -> MDAppBar {
        let appBar = self.init()
        appBar.backgroundColor = backgroundColor

        appBar.lblTitle.text = title
        appBar.lblTitle.textColor = backgroundColor.inverseColor()
        
        appBar.btnBack.tintColor = backgroundColor.inverseColor()
        
        appBar.setupUI()
        return appBar
    }
    
    func setupUI() {
        self.addSubview(self.btnBack)
        self.btnBack.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(30)
        }
        
        self.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.left.equalTo(self.btnBack.snp.right).inset(-10)
            make.centerY.equalTo(self.btnBack)
            make.right.lessThanOrEqualToSuperview().inset(50)
        }
    }
}
