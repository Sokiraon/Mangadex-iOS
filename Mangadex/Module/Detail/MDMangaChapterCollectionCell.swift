//
//  MDMangaChapterCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

class MDMangaChapterCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.backgroundColor = MDColor.get(.lightGrayE5E5E5)
        contentView.layer.cornerRadius = 5
        
        contentView.addSubview(self.lblTitle)
        self.lblTitle.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(15)
        }
    }
    
    lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
}
