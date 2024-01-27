//
//  MangaChapterCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit
import SnapKit

class MangaChapterCollectionCell: UICollectionViewCell {
    
    let containerView = UIView()
    let chapterView = ChapterView()
    let divider = LineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        contentView.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        
        containerView.addSubview(chapterView)
        chapterView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        containerView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(chapterView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
