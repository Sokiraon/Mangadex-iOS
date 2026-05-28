//
//  BrowseMangaPopularCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/08.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import SkeletonView

class BrowseMangaPopularCell: UICollectionViewCell {

    private let cardView = CardView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let coverImageView = UIImageView()
    private let titleLabel = UILabel(fontSize: 20, fontWeight: .medium,
                                     numberOfLines: 2)
    private let descrLabel = UILabel(fontSize: 17, color: .secondaryText,
                                     numberOfLines: 0)
    
    private func setupUI() {
        cardView.cornerRadius = 8
        cardView.shadowCornerRadius = 8
        cardView.shadowOpacity = 0.14
        cardView.shadowOffset = .zero
        cardView.shadowRadius = 6
        cardView.shadowPathInset = UIEdgeInsets(
            top: 3,
            left: 3,
            bottom: 3,
            right: 3
        )
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.addSubview(coverImageView)
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 8
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.isSkeletonable = true
        coverImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(8)
            make.width.equalTo(96)
            make.height.equalTo(144)
        }
        
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalTo(coverImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
        }
        
        cardView.addSubview(descrLabel)
        descrLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(coverImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }
    
    func setContent(mangaModel: MangaModel) {
        coverImageView.showAnimatedSkeleton()
        coverImageView.kf.setImage(with: mangaModel.coverURLHD) { _ in
            self.coverImageView.hideSkeleton()
        }
        titleLabel.text = mangaModel.attributes.localizedTitle
        descrLabel.text = mangaModel.attributes.localizedDescription
    }
}
