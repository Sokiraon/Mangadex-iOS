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
    
    let chapterView = ChapterView()
    let divider = LineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth - 2 * 16)
        }
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        contentView.addSubview(chapterView)
        chapterView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(chapterView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
