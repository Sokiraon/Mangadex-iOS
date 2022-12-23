//
//  MDMangaListCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit
import PromiseKit
import SnapKit
import Kingfisher

class MDMangaListCellInfoItem: UIView {
    private let ivIcon = UIImageView()
    let lblInfo = UILabel(fontSize: 15, color: .black2D2E2F)
    
    convenience init(icon: UIImage?, defaultText: String = "N/A") {
        self.init()
        ivIcon.image = icon
        ivIcon.tintColor = .black2D2E2F
        lblInfo.text = defaultText
        
        addSubview(ivIcon)
        ivIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        addSubview(lblInfo)
        lblInfo.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.centerY.equalTo(ivIcon)
            make.leading.equalTo(ivIcon.snp.trailing).offset(8)
            make.width.greaterThanOrEqualTo(40)
        }
    }
}

class MDMangaListCollectionCell: UICollectionViewCell {
    
    private let ivCover = UIImageView(imageNamed: "manga_cover_default")
    private let titleLabel = UILabel(
        fontSize: 18,
        fontWeight: .medium,
        color: .black2D2E2F
    )
    private let infoAuthor = MDMangaListCellInfoItem(
        icon: .init(named: "icon_draw"),
        defaultText: "kAuthorUnknown".localized()
    )
    private let infoRate = MDMangaListCellInfoItem(icon: .init(named: "icon_grade"))
    private let infoFollow = MDMangaListCellInfoItem(icon: .init(named: "icon_bookmark_border"))
    
    private let statusView = UIView(backgroundColor: .fromHex("219653"))
    private let statusLabel = UILabel(
        fontSize: 15, fontWeight: .medium, color: .black2D2E2F
    ).apply { label in
        label.text = "kMangaOngoing".localized()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public static let cellHeight = 105.0
    
    private func setupUI() {
        layer.theme_shadowColor = UIColor.themePrimaryCgPicker
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.theme_backgroundColor = UIColor.themeLightestPicker
        
        contentView.addSubview(ivCover)
        ivCover.clipsToBounds = true
        ivCover.contentMode = .scaleAspectFill
        ivCover.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(MDMangaListCollectionCell.cellHeight)
            make.width.equalTo(MDMangaListCollectionCell.cellHeight * 2 / 3)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(ivCover.snp.right).offset(15)
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(15)
        }
        
        contentView.addSubview(infoRate)
        infoRate.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(infoFollow)
        infoFollow.snp.makeConstraints { make in
            make.leading.equalTo(infoRate.snp.trailing).offset(16)
            make.centerY.equalTo(infoRate)
        }
        
        contentView.addSubview(infoAuthor)
        infoAuthor.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(infoRate.snp.top).offset(-8)
        }
        
        contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.trailing.equalTo(titleLabel)
            make.centerY.equalTo(infoFollow)
        }
        
        contentView.addSubview(statusView)
        statusView.layer.cornerRadius = 4
        statusView.snp.makeConstraints { make in
            make.size.equalTo(8)
            make.centerY.equalTo(statusLabel)
            make.trailing.equalTo(statusLabel.snp.leading).offset(-8)
        }
    }
    
    func update(mangaModel model: MDMangaItemDataModel) {
        titleLabel.text = model.attributes.localizedTitle
        if model.attributes.status == "completed" {
            statusView.backgroundColor = .fromHex("eb5757")
            statusLabel.text = "kMangaCompleted".localized()
        } else {
            statusView.backgroundColor = .fromHex("219653")
            statusLabel.text = "kMangaOngoing".localized()
        }
        if let coverArt = model.coverArts.first {
            let urlStr = "\(HostUrl.uploads.rawValue)/covers/\(model.id!)/\(coverArt.fileName!).256.jpg"
            ivCover.kf.setImage(
                with: URL(string: urlStr),
                placeholder: UIImage(named: "manga_cover_default")
            )
        }
        if let authorName = model.authors.first?.attributes?.name {
            infoAuthor.lblInfo.text = authorName
        }
        _ = firstly {
            MDRequests.Manga.getStatistics(mangaId: model.id)
        }
            .done { statistics in
                DispatchQueue.main.async {
                    if statistics.follows != nil {
                        let num = statistics.follows!.intValue
                        if num > 1000000 {
                            self.infoFollow.lblInfo.text = "\(num / 1000000)M"
                        } else if num > 1000 {
                            self.infoFollow.lblInfo.text = "\(num / 1000)K"
                        } else {
                            self.infoFollow.lblInfo.text = "\(num)"
                        }
                    }
                    if statistics.rating != nil {
                        let nf = NumberFormatter().apply { formatter in
                            formatter.numberStyle = .decimal
                            formatter.minimumFractionDigits = 2
                            formatter.maximumFractionDigits = 2
                        }
                        if statistics.rating?.bayesian != nil {
                            self.infoRate.lblInfo.text = nf.string(
                                from: statistics.rating!.bayesian!
                            )
                        } else if statistics.rating?.average != nil {
                            self.infoRate.lblInfo.text = nf.string(
                                from: statistics.rating!.average!
                            )
                        }
                    }
                }
            }
    }
    
    func getTitle() -> String {
        titleLabel.text ?? ""
    }
}
