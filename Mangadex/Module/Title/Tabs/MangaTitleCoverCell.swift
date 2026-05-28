//
//  MangaTitleCoverCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/29.
//

import Foundation
import UIKit
import Kingfisher
import Agrume

private class MangaTitleCoverGradientView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        gradientLayer.startPoint = .init(x: 0, y: 0)
        gradientLayer.endPoint = .init(x: 0, y: 1)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
    }
}

class MangaTitleCoverCell: UICollectionViewCell {

    private let cardView = CardView()
    private let imageContainerView = UIView()
    private let imageView = UIImageView()
    private let bottomView = MangaTitleCoverGradientView()
    private let title = UILabel(fontSize: 18, fontWeight: .medium, color: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.cornerRadius = 16
        cardView.shadowCornerRadius = 16
        cardView.shadowOpacity = 0.14
        cardView.shadowOffset = CGSize(width: 0, height: 2)
        cardView.shadowRadius = 6
        cardView.shadowPathInset = .zero
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.addSubview(imageContainerView)
        imageContainerView.clipsToBounds = true
        imageContainerView.layer.cornerRadius = 16
        imageContainerView.layer.cornerCurve = .continuous
        imageContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageContainerView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        imageContainerView.addSubview(title)
        title.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(bottomView).inset(12)
        }
    }
    
    func setContent(with mangaModel: MangaModel,
                    coverModel: CoverArtModel) {
        imageView.kf.setImage(with: coverModel.getHDUrl(mangaId: mangaModel.id))
        if let volume = coverModel.attributes.volume {
            title.text = "manga.detail.cover.volume".localizedFormat(volume)
        } else {
            title.text = "manga.detail.cover.noVolume".localized()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
