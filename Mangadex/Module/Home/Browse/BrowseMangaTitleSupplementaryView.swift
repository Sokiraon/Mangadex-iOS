//
//  BrowseMangaTitleSupplementaryView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/08.
//

import Foundation
import UIKit
import SnapKit

class BrowseMangaTitleSupplementaryView: UICollectionReusableView {
    let label = UILabel(fontSize: 23, fontWeight: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
}
