//
//  MangaDownloadVolumeHeaderView.swift
//  Mangadex
//
//  Created by John Rion on 2024/06/20.
//

import Foundation
import UIKit
import SnapKit

class MangaDownloadVolumeHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel(fontSize: 18, fontWeight: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
