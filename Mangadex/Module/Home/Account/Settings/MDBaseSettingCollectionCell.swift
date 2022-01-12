//
//  MDBaseSettingCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/12.
//

import Foundation
import UIKit

class MDBaseSettingCollectionCell: UICollectionViewCell {
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
}
