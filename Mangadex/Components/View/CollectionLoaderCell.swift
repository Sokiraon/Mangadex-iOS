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
        addSubview(vLoading)
        vLoading.startAnimating()
        vLoading.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
    }
    
    override func prepareForReuse() {
        vLoading.startAnimating()
    }
}
