//
//  DownloadsMangaCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/11.
//

import Foundation
import UIKit
import Kingfisher
import SnapKit

class DownloadsMangaCollectionCell: UICollectionViewCell {
    private let ivCover = UIImageView()
    private let lblTitle = UILabel(
        fontSize: 18, fontWeight: .medium, numberOfLines: 2
    )
    
    private let infoAuthor = MangaListCellInfoItem(
        icon: .init(named: "icon_draw"),
        defaultText: "kAuthorUnknown".localized()
    )
    private let lblSize = UILabel(fontSize: 15)
    private let lblCount = UILabel(fontSize: 15)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        layer.theme_shadowColor = UIColor.themePrimaryCgPicker
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.theme_backgroundColor = UIColor.themeLightestPicker
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth - 2 * 10)
        }
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        contentView.addSubview(ivCover)
        ivCover.clipsToBounds = true
        ivCover.contentMode = .scaleAspectFill
        ivCover.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(105)
            make.width.equalTo(105 * 2 / 3)
        }
        
        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.left.equalTo(ivCover.snp.right).offset(15)
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(15)
        }
        
        contentView.addSubview(infoAuthor)
        infoAuthor.snp.makeConstraints { make in
            make.left.equalTo(lblTitle)
            make.bottom.equalToSuperview().inset(10)
        }
        
//        contentView.addSubview(lblSize)
//        lblSize.snp.makeConstraints { make in
//            make.left.equalTo(lblTitle)
//            make.bottom.equalToSuperview().inset(10)
//        }
        
        contentView.addSubview(lblCount)
        lblCount.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    func update(mangaModel: LocalMangaModel) {
        ivCover.kf.setImage(with: mangaModel.coverURL)
        lblTitle.text = mangaModel.info.attributes.localizedTitle
        lblCount.text = "kDownloadedMangaChapterCount".localizedFormat(mangaModel.chapterURLs.count)
        infoAuthor.text = mangaModel.info.primaryAuthorName
    }
}
