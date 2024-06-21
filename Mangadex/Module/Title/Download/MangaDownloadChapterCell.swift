//
//  MangaDownloadChapterCell.swift
//  Mangadex
//
//  Created by John Rion on 2024/06/19.
//

import Foundation
import UIKit
import SnapKit

class MangaDownloadChapterCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = MDLayout.native1px * 2
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private(set) var checked = false {
        didSet {
            setAppearanceForCheckedState()
        }
    }
    
    func setChecked(_ newState: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.checked = newState
        }
    }
    
    func setAppearanceForCheckedState() {
        if checked {
            titleLabel.textColor = .white
            contentView.backgroundColor = .themeDark
            contentView.layer.borderColor = UIColor.themeDark.cgColor
        } else {
            titleLabel.textColor = .black
            contentView.backgroundColor = .white
            contentView.layer.borderColor = UIColor.darkerGray565656.cgColor
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checked = false
    }
}
