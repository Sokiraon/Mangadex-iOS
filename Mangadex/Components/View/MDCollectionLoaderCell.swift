//
//  MDCollectionLoaderCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/3/11.
//

import Foundation
import UIKit

/// A loader cell used in collectionView to represent the **loading** state.
class MDCollectionLoaderCell: UICollectionViewCell {
    
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
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(16)
        }
    }
    
    override func prepareForReuse() {
        vLoading.startAnimating()
    }
}
