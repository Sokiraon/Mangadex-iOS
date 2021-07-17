//
//  MDMangaChapterSectionHeader.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

class MDSectionHeaderView: UIView {
    
    static func initWithTitle(_ title: String) -> MDSectionHeaderView {
        let view = self.init()
        view.lblSection.text = title
        view.setupUI()
        return view
    }
    
    func setupUI() {
        addSubview(lblSection)
        lblSection.snp.makeConstraints { make in
            make.top.equalToSuperview()
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
        view.backgroundColor = MDColor.get(.grayDFDFDF)
        return view
    }()
}
