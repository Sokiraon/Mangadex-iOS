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

class MangaTitleCoverCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let bottomView = UIView()
    let bottomGradient = CAGradientLayer().apply { layer in
        layer.startPoint = .init(x: 0, y: 0)
        layer.endPoint = .init(x: 0, y: 1)
        layer.colors = [
            UIColor.clear,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
    }
    let title = UILabel(fontSize: 18, fontWeight: .medium, color: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        layoutIfNeeded()
        bottomGradient.frame = .init(origin: .zero,
                                     size: bottomView.frame.size)
        bottomView.layer.addSublayer(bottomGradient)
        
        addSubview(title)
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
    }
}
