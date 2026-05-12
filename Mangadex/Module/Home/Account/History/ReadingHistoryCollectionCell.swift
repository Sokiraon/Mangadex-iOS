//
//  ReadingHistoryCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2025/12/21.
//

import UIKit
import SnapKit
import Kingfisher

class ReadingHistoryCollectionCell: UICollectionViewCell {
    var onContinue: (() -> Void)?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let cardView = CardView().apply { view in
        view.borderWidth = 1
        view.borderColor = UIColor.white.withAlphaComponent(0.7)
    }
    
    private let coverImage = UIImageView()
    private let titleLabel = UILabel()
    private let progressLabel = UILabel()
    private let dateLabel = UILabel()
    private let readButton: UIButton
    
    override init(frame: CGRect) {
        var config = UIButton.Configuration.tinted()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12)
        config.image = UIImage(
            systemName: "play.fill",
            withConfiguration: imageConfig
        )?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .leading
        config.imagePadding = 4
        config.title = String(localized: "Continue")
        config.cornerStyle = .capsule
        config.baseForegroundColor = .themeDark
        config.baseBackgroundColor = .themeDark
        config.buttonSize = .medium
        readButton = UIButton(configuration: config)
        
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        cardView.addSubview(coverImage)
        coverImage.clipsToBounds = true
        coverImage.layer.cornerRadius = 8
        coverImage.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(12)
            make.width.equalTo(72)
            make.height.equalTo(96)
        }
        
        cardView.addSubview(readButton)
        readButton.addAction(UIAction { [weak self] _ in
            self?.onContinue?()
        }, for: .touchUpInside)
        readButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
        
        cardView.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .primaryText
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImage).offset(8)
            make.left.equalTo(coverImage.snp.right).offset(8)
            make.right.lessThanOrEqualTo(readButton.snp.left).offset(-8)
        }
        
        cardView.addSubview(progressLabel)
        progressLabel.textColor = .secondaryText
        progressLabel.font = .systemFont(ofSize: 13, weight: .light)
        progressLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(coverImage).offset(-4)
        }
        
        cardView.addSubview(dateLabel)
        dateLabel.textColor = .secondaryText
        dateLabel.font = .systemFont(ofSize: 13, weight: .light)
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(progressLabel)
            make.right.equalTo(readButton)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onContinue = nil
        coverImage.kf.cancelDownloadTask()
        coverImage.image = nil
    }
    
    func setContent(with data: ReadingHistoryDTO) {
        coverImage.kf.setImage(with: data.coverURL)
        titleLabel.text = data.mangaTitle
        progressLabel.text = data.chapterTitle
        dateLabel.text = DateHelper
            .dateStringFromNow(date: data.updatedAt)
    }
}
