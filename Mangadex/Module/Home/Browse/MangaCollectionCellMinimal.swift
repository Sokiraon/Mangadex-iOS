//
//  MangaCollectionCellMinimal.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

class MangaCollectionCellMinimal: UICollectionViewCell {
    let coverView = UIImageView()
    let titleLabel = UILabel(fontSize: 17, numberOfLines: 2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 4
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(96)
            make.height.equalTo(135)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverView.snp.bottom).offset(12)
            make.left.right.equalTo(coverView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setContent(mangaModel: MangaModel) {
        coverView.kf.setImage(with: mangaModel.coverURL)
        titleLabel.text = mangaModel.attributes.localizedTitle
    }
}
