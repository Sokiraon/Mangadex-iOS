//
//  MDAppBar.swift
//  Mangadex
//
//  Created by edz on 2021/6/8.
//

import Foundation
import UIKit

class MDAppBar: UIView {
    var title: String
    var color: UIColor
    var arrowBack: UIButton!
    
    init(title: String, color: UIColor? = nil) {
        self.title = title
        if ((color) != nil) {
            self.color = color!
        } else {
            self.color = .white
        }
        
        self.arrowBack = {
            let button = UIButton()
            button.setImage(UIImage(named: "baseline_arrow_back_black_36pt"), for: .normal)
            button.contentMode = .center
            button.tintColor = .black
            button.snp.makeConstraints { make in
                make.width.height.equalTo(30)
            }
            return button
        }()
        
        super.init(frame: CGRect.zero)
        self.setupUI()
    }
    
    func setupUI() {
        self.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.safeAreaSize().width)
        }
        
        self.addSubview(self.arrowBack)
        self.arrowBack.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        let titleLabel = UILabel.initWithText(self.title, ofFontWeight: .regular, andSize: 20)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.arrowBack.snp.right).inset(-10)
            make.centerY.equalTo(self.arrowBack)
            make.right.lessThanOrEqualToSuperview().inset(50)
        }
        
//        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
