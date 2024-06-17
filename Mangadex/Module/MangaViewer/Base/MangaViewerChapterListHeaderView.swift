//
//  MangaViewerChapterListHeaderView.swift
//  Mangadex
//
//  Created by John Rion on 2024/06/16.
//

import Foundation
import UIKit
import SnapKit

class MangaViewerChapterListHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel(fontSize: 17, fontWeight: .bold, color: .grayDFDFDF)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .black
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
