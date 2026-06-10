//
//  MangaListCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit
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

    private let cardView = CardView()

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
            make.height.greaterThanOrEqualTo(105)
        }

        cardView.addSubview(ivCover)
        ivCover.clipsToBounds = true
        ivCover.layer.cornerRadius = 8
        ivCover.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        ivCover.contentMode = .scaleAspectFill
        ivCover.isSkeletonable = true
        ivCover.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(105)
            make.width.equalTo(ivCover.snp.height).multipliedBy(2.0 / 3.0)
        }

        cardView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.left.equalTo(ivCover.snp.right).offset(16)
            make.top.equalToSuperview().inset(12)
            make.right.equalToSuperview().inset(16)
        }

        cardView.addSubview(infoRate)
        infoRate.isSkeletonable = true
        infoRate.snp.makeConstraints { make in
            make.leading.equalTo(lblTitle)
            make.bottom.equalToSuperview().inset(12)
        }

        cardView.addSubview(infoFollow)
        infoFollow.isSkeletonable = true
        infoFollow.snp.makeConstraints { make in
            make.leading.equalTo(infoRate.snp.trailing).offset(16)
            make.centerY.equalTo(infoRate)
        }

        cardView.addSubview(infoAuthor)
        infoAuthor.snp.makeConstraints { make in
            make.leading.equalTo(lblTitle)
            make.bottom.equalTo(infoRate.snp.top).offset(-8)
        }

        cardView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.trailing.equalTo(lblTitle)
            make.centerY.equalTo(infoFollow)
        }

        cardView.addSubview(statusView)
        statusView.layer.cornerRadius = 4
        statusView.snp.makeConstraints { make in
            make.size.equalTo(8)
            make.centerY.equalTo(statusLabel)
            make.trailing.equalTo(statusLabel.snp.leading).offset(-8)
        }
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        guard let collectionView = superview as? UICollectionView else {
            return attributes
        }

        let horizontalInset = collectionView.adjustedContentInset.left
            + collectionView.adjustedContentInset.right
        let targetWidth = collectionView.bounds.width - horizontalInset
        guard targetWidth > 0 else {
            return attributes
        }
        let targetSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittedSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attributes.size = CGSize(width: targetWidth, height: ceil(fittedSize.height))
        return attributes
    }

    private var representedMangaID: String?

    func setContent(mangaModel model: MangaModel) {
        representedMangaID = model.id
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

            Task { @MainActor in
                let data = try await Requests.Manga.getStatistics(mangaId: model.id)
                guard self.representedMangaID == model.id else { return }
                self.infoFollow.text = data.followsString
                self.infoRate.text = data.ratingString
            }
        }
    }
}
