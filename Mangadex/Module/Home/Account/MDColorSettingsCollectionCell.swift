//
//  MDColorSettingsCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/1.
//

import Foundation
import UIKit
import SwiftTheme

class MDColorSettingsCollectionCell: UICollectionViewCell {
    
    private var vColor = UIView()
    private var vColorBorder = UIView()
    private var lblColor = UILabel(fontSize: 17, fontWeight: .medium, color: .black2D2E2F, numberOfLines: 1, scalable: true)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.addSubview(vColorBorder)
        vColorBorder.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.top.equalToSuperview().inset(6)
            make.centerX.equalToSuperview()
        }
        vColorBorder.layer.cornerRadius = 25
        
        contentView.addSubview(vColor)
        vColor.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.centerX.centerY.equalTo(vColorBorder)
        }
        vColor.layer.cornerRadius = 24
        
        contentView.addSubview(lblColor)
        lblColor.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        lblColor.textAlignment = .center
    }
    
    private var index: Int!
    
    func setWithIndex(_ index: Int) {
        let color = MDColor.colorFromHex(
            MDThemeColors.allCases[index].rawValue
        )
        let halfColor = color.withAlphaComponent(0.5)
        
        vColor.backgroundColor = color
        vColorBorder.backgroundColor = halfColor
        lblColor.text = "\(MDThemeColors.allCases[index])".capitalized
        
        self.index = index
        updateUIIfNeeded()
    }
    
    func updateUIIfNeeded() {
        setSelected(self.index == ThemeManager.currentThemeIndex)
    }
    
    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.5) { [self] in
            if (selected) {
                vColorBorder.isHidden = false
                lblColor.textColor = vColor.backgroundColor
            } else {
                vColorBorder.isHidden = true
                lblColor.textColor = vColorBorder.backgroundColor
            }
        }
    }
}
