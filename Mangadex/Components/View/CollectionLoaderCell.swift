//
//  CollectionLoaderCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/3/11.
//

import Foundation
import UIKit

/// A loader cell used in collectionView to represent the **loading** state.
class CollectionLoaderCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private let vLoading = UIActivityIndicatorView()
    
    private func setupUI() {
        contentView.addSubview(vLoading)
        vLoading.startAnimating()
        vLoading.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
            make.top.bottom.equalToSuperview().inset(15)
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
    
    override func prepareForReuse() {
        vLoading.startAnimating()
    }
}
