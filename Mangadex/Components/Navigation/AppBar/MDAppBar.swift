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
        button.setImage(UIImage(named: "icon_arrow_back_white"), for: .normal)
        button.contentMode = .scaleToFill
        return button
    }()
    
    lazy var lblTitle: UILabel = UILabel.initWithText("", ofFontWeight: .regular, andSize: 17)
    
    convenience init(title: String, backgroundColor: UIColor? = nil) {
        self.init()
        
        if (backgroundColor != nil) {
            self.backgroundColor = backgroundColor!
        } else {
            theme_backgroundColor = UIColor.theme_primaryColor
        }
        lblTitle.text = title
        lblTitle.textColor = backgroundColor?.inverseColor() ?? .white
        
        setupUI()
    }
    
    func setupUI() {
        self.addSubview(self.btnBack)
        self.btnBack.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        self.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.snp.makeConstraints { make in
            make.left.equalTo(self.btnBack.snp.right).offset(15)
            make.centerY.equalTo(self.btnBack)
            make.centerX.equalTo(self)
        }
    }
}
