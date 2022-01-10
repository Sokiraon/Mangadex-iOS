//
//  MDColorSettingCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import SnapKit

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
        addSubview(lblColor)
        lblColor.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.centerX.equalToSuperview()
        }
        
        addSubview(vColor)
        vColor.layer.cornerRadius = 10
        vColor.snp.makeConstraints { make in
            make.top.equalTo(lblColor.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
    }
    
    func setColor(_ color: MDThemeColors) {
        lblColor.textColor = MDColor.colorFromHex(color.rawValue)
        lblColor.text = "\(color)".capitalized
        vColor.backgroundColor = MDColor.colorFromHex(color.rawValue)
    }
}
