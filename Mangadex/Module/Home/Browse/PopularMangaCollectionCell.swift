//
//  PopularMangaCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/08.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

class PopularMangaCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let coverImageView = UIImageView()
    private let bottomArea = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let titleLabel = UILabel(fontSize: 20, fontWeight: .medium,
                                     color: .white, numberOfLines: 1)
    
    private func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 8
        
        contentView.addSubview(coverImageView)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(bottomArea)
        bottomArea.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerY.equalTo(bottomArea)
        }
    }
    
    func setContent(mangaModel: MangaModel) {
        coverImageView.kf.setImage(with: mangaModel.coverURLOriginal)
        titleLabel.text = mangaModel.attributes.localizedTitle
    }
}
