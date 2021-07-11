//
//  MDMangaDetailInfoViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import UIKit
import SnapKit

class MDMangaDetailInfoViewController: MDViewController {
    private var mangaItem: MangaItem!
    
    private lazy var vScroll = UIScrollView()
    private lazy var vScrollContent = UIView()
    private lazy var headerDescription = MDSectionHeaderView.initWithTitle("kDescription".localized())
    private lazy var lblDescription: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var headerTags = MDSectionHeaderView.initWithTitle("kTags".localized())
    
    func updateWithMangaItem(_ item: MangaItem) {
        lblDescription.text = item.description
    }
    
    override func setupUI() {
        view.addSubview(vScroll)
        vScroll.alwaysBounceVertical = true
        vScroll.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(50)
            make.left.right.bottom.equalToSuperview()
        }
        
        vScroll.addSubview(vScrollContent)
        vScrollContent.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
    
        vScrollContent.addSubview(headerDescription)
        headerDescription.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(5)
        }
        
        vScrollContent.addSubview(lblDescription)
        lblDescription.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(headerDescription.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        
        vScrollContent.addSubview(headerTags)
        headerTags.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(lblDescription.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}
