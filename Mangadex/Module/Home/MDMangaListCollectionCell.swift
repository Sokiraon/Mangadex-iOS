//
//  MDMangaListCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit

class MDMangaCellTagItem: UIView {
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    let contentLabel = UILabel(fontSize: 15, color: .white)
    
    init() {
        super.init(frame: .zero)
        
        self.layer.cornerRadius = 3
        self.theme_backgroundColor = UIColor.theme_primaryColor
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
}

class MDMangaListCollectionCell: UICollectionViewCell {
    
    private let ivCover = UIImageView(imageNamed: "manga_cover_default")
    private let titleLabel = UILabel(
        fontSize: 18,
        fontWeight: .medium,
        color: .black2D2E2F,
        numberOfLines: 2,
        scalable: true
    )
    private let statusTag = MDMangaCellTagItem()
    private let updateTag = MDMangaCellTagItem()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public static let cellHeight = 105.0
    
    func setupUI() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.theme_backgroundColor = UIColor.theme_lightColor
        
        contentView.layer.theme_borderColor = UIColor.theme_primaryCgColor
        contentView.layer.borderWidth = 1
        
        contentView.addSubview(ivCover)
        ivCover.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(MDMangaListCollectionCell.cellHeight)
            make.width.equalTo(MDMangaListCollectionCell.cellHeight * 2 / 3)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(ivCover.snp.right).offset(15)
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(statusTag)
        statusTag.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(8)
        }
        
        contentView.addSubview(updateTag)
        updateTag.snp.makeConstraints { make in
            make.top.equalTo(statusTag)
            make.right.equalToSuperview().inset(10)
        }
    }
    
    func setContent(mangaItem item: MangaItem) {
        titleLabel.text = item.title
        if (item.status == "ongoing") {
            statusTag.contentLabel.text = "kMangaOngoing".localized()
        } else {
            statusTag.contentLabel.text = "kMangaCompleted".localized()
        }
        updateTag.contentLabel.text = "kMangaLastUpdate".localizedPlural(
            MDFormatter.formattedDateString(fromISODateString: item.updatedAt)
        )
        
        MDHTTPManager()
            .getMangaCoverUrlById(item.coverId, forManga: item.id) { url in
                DispatchQueue.main.async {
                    self.ivCover
                        .kf
                        .setImage(with: url, placeholder: UIImage(named: "manga_cover_default"))
                }
            }
    }
    
    func getTitle() -> String {
        titleLabel.text ?? ""
    }
}
