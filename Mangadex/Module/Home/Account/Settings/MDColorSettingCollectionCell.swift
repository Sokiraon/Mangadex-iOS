//
//  MDColorSettingCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import SnapKit
import UIKit

class MDColorSettingCollectionCell: UICollectionViewCell {
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private let lblColor = UILabel(fontSize: 18)
    private let vColor = UIView()
    
    func setupUI() {
        backgroundColor = .white
        
        layer.borderColor = UIColor.lightestGrayF5F5F5.cgColor
        layer.borderWidth = 2
        
        addSubview(lblColor)
        lblColor.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        addSubview(vColor)
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
            case .themeCerulean:
                return "Cerulean".localized()
            case .themeTeal:
                return "Teal".localized()
            case .themeCoral:
                return "Coral".localized()
            default:
                return ""
            }
        }()
    }
}
