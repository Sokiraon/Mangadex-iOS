//
//  MangaListCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit
import PromiseKit
import SnapKit
import Kingfisher
import SkeletonView

class MangaListCellInfoItem: UIView {
    private let ivIcon = UIImageView()
    private let lblInfo = UILabel(fontSize: 15)
    
    convenience init(icon: UIImage?, defaultText: String = "N/A") {
        self.init()
        isSkeletonable = true
        ivIcon.image = icon
        ivIcon.tintColor = .black2D2E2F
        lblInfo.text = defaultText
        lblInfo.isSkeletonable = true
        
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
    
    var text: String? {
        didSet {
            hideSkeleton()
            lblInfo.text = text
        }
    }
}

class MangaListCollectionCell: UICollectionViewCell {
    
    private let ivCover = UIImageView()
    private let lblTitle = UILabel(
        fontSize: 18,
        fontWeight: .medium,
        color: .black2D2E2F
    )
    private let infoAuthor = MangaListCellInfoItem(
        icon: .init(named: "icon_draw"),
        defaultText: "kAuthorUnknown".localized()
    )
    private let infoRate = MangaListCellInfoItem(icon: .init(named: "icon_grade"))
    private let infoFollow = MangaListCellInfoItem(icon: .init(named: "icon_bookmark_border"))
    
    private let statusView = UIView().apply { view in
        view.backgroundColor = .fromHex("219653")
    }
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
    
    private func setupUI() {
        layer.theme_shadowColor = UIColor.themePrimaryCgPicker
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = MDLayout.scale
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.theme_backgroundColor = UIColor.themeLightestPicker
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth - 2 * 10)
            make.height.equalTo(105)
        }
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        contentView.addSubview(ivCover)
        ivCover.clipsToBounds = true
        ivCover.contentMode = .scaleAspectFill
        ivCover.isSkeletonable = true
        ivCover.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(105 * 2 / 3)
        }
        
        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.left.equalTo(ivCover.snp.right).offset(15)
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(15)
        }
        
        contentView.addSubview(infoRate)
        infoRate.isSkeletonable = true
        infoRate.snp.makeConstraints { make in
            make.leading.equalTo(lblTitle)
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(infoFollow)
        infoFollow.isSkeletonable = true
        infoFollow.snp.makeConstraints { make in
            make.leading.equalTo(infoRate.snp.trailing).offset(16)
            make.centerY.equalTo(infoRate)
        }
        
        contentView.addSubview(infoAuthor)
        infoAuthor.snp.makeConstraints { make in
            make.leading.equalTo(lblTitle)
            make.bottom.equalTo(infoRate.snp.top).offset(-8)
        }
        
        contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.trailing.equalTo(lblTitle)
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
    
    func setContent(mangaModel model: MangaModel) {
        lblTitle.text = model.attributes.localizedTitle
        if model.attributes.status == "completed" {
            statusView.backgroundColor = .fromHex("eb5757")
            statusLabel.text = "kMangaCompleted".localized()
        } else {
            statusView.backgroundColor = .fromHex("219653")
            statusLabel.text = "kMangaOngoing".localized()
        }
        ivCover.showAnimatedSkeleton()
        ivCover.kf.setImage(with: model.coverURL) { _ in
            self.ivCover.hideSkeleton()
        }
        infoAuthor.text = model.primaryAuthorName
        
        if let statistics = model.statistics {
            infoFollow.text = statistics.followsString
            infoRate.text = statistics.ratingString
        } else {
            infoRate.showAnimatedSkeleton()
            infoFollow.showAnimatedSkeleton()
            _ = Requests.Manga.getStatistics(mangaId: model.id)
                .done { statistics in
                    model.statistics = statistics
                    self.infoFollow.text = statistics.followsString
                    self.infoRate.text = statistics.ratingString
                }
        }
    }
}
