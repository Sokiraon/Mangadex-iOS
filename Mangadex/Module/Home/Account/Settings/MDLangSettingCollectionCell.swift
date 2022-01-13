//
//  MDLangSettingCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/12.
//

import Foundation
import UIKit
import FlagKit

class MDLangSettingCollectionCell: MDBaseSettingCollectionCell {
    
    private let lblLang = UILabel(fontSize: 18)
    private let vFlagMain = UIImageView()
    private let vFlagAlt = UIImageView()
    
    override func setupUI() {
        super.setupUI()
        
        contentView.addSubview(lblLang)
        lblLang.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
    }
    
    func setFlags(lang: String, regionCode: String) {
        lblLang.text = lang
        
        if regionCode.contains("/") {
            let codes = regionCode.split(separator: "/")
            let code1 = String(codes[0]), code2 = String(codes[1])
            vFlagMain.image = Flag(countryCode: code1)?.originalImage
            vFlagAlt.image = Flag(countryCode: code2)?.originalImage
            
            contentView.addSubview(vFlagMain)
            vFlagMain.snp.makeConstraints { make in
                make.top.equalTo(lblLang.snp.bottom).offset(12)
                make.right.equalTo(contentView.snp.centerX).offset(-5)
            }
            
            contentView.addSubview(vFlagAlt)
            vFlagAlt.snp.makeConstraints { make in
                make.top.equalTo(vFlagMain)
                make.left.equalTo(contentView.snp.centerX).offset(5)
            }
        } else {
            vFlagMain.image = Flag(countryCode: regionCode)?.originalImage
            
            contentView.addSubview(vFlagMain)
            vFlagMain.snp.makeConstraints { make in
                make.top.equalTo(lblLang.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
            }
        }
    }
}
