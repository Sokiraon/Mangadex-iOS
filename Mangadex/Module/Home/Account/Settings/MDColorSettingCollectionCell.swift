//
//  MDColorSettingCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import SnapKit
import UIKit

class MDColorSettingCollectionCell: MDBaseSettingCollectionCell {
    
    private let lblColor = UILabel(fontSize: 18)
    private let vColor = UIView()
    
    override func setupUI() {
        super.setupUI()
        
        contentView.addSubview(lblColor)
        lblColor.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(vColor)
        vColor.layer.cornerRadius = 10
        vColor.snp.makeConstraints { make in
            make.top.equalTo(lblColor.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
    }
    
    func setColor(_ color: UIColor) {
        lblColor.textColor = color
        vColor.backgroundColor = color
        
        lblColor.text = { () -> String in
            switch color {
            case .cerulean400:
                return "Cerulean".localized()
            case .teal300:
                return "Teal".localized()
            case .coral400:
                return "Coral".localized()
            default:
                return ""
            }
        }()
    }
}
