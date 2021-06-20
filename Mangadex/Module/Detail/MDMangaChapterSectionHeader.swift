//
//  MDMangaChapterSectionHeader.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

class MDMangaChapterSectionHeader: UICollectionReusableView {
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    func setupUI() {
        addSubview(lblSection)
        lblSection.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
        }
        
        addSubview(vDivider)
        vDivider.snp.makeConstraints { make in
            make.top.equalTo(lblSection.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    lazy var lblSection = UILabel()
    lazy var vDivider: UIView = {
        let view = UIView()
        view.backgroundColor = MDColor.get(.lightGrayE5E5E5)
        return view
    }()
}
