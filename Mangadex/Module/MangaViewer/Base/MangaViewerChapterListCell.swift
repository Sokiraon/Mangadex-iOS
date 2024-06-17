//
//  MangaViewerChapterListCell.swift
//  Mangadex
//
//  Created by John Rion on 2024/06/17.
//

import Foundation
import UIKit
import SnapKit

class MangaViewerChapterListCell: UICollectionViewCell {
    private let stripView = UIView()
    private let titleLabel = UILabel(fontSize: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stripView)
        stripView.alpha = 0
        stripView.theme_backgroundColor = UIColor.themePrimaryPicker
        stripView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(4)
        }
        
        addSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var isCurrent = false {
        didSet {
            if isCurrent {
                stripView.alpha = 1
                titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                backgroundColor = .darkerGray565656
            } else {
                stripView.alpha = 0
                titleLabel.font = .systemFont(ofSize: 16)
                backgroundColor = .clear
            }
        }
    }
    
    func setContent(title: String, isCurrent: Bool) {
        titleLabel.text = title
        self.isCurrent = isCurrent
    }
    
    func setHighlighted(_ isHighlighted: Bool) {
        if isHighlighted {
            backgroundColor = .darkerGray565656
        } else if !isCurrent {
            backgroundColor = .clear
        }
    }
}
