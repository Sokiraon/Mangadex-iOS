//
//  MDMangaDetailChapterCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit
import SnapKit

/// The loader cell, used for representing the loading state.
class MDCollectionLoadingCell: UICollectionViewCell {
    
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
}

class MDMangaDetailChapterCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private let lblChapter = UILabel(fontSize: 16, fontWeight: .medium)
    private let lblUpdate = UILabel(fontSize: 15, color: .secondaryText)
    private let vDivider = UIView(style: .line)
    
    private lazy var ivGroup = UIImageView(imageNamed: "icon_group", color: .secondaryText)
    private lazy var lblGroup = UILabel(fontSize: 15, color: .secondaryText)
    
    private func setupUI() {
        let contentViewEdgeInset = 16.0
        contentView.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth - 2 * contentViewEdgeInset).priority(.required)
        }
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        contentView.addSubview(lblChapter)
        lblChapter.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.left.right.equalToSuperview()
        }
        
        contentView.addSubview(lblUpdate)
        lblUpdate.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(lblChapter.snp.bottom).offset(8)
        }
        
        contentView.addSubview(vDivider)
        vDivider.snp.makeConstraints { make in
            make.top.equalTo(lblUpdate.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func update(model: MDMangaChapterInfoModel, lastViewed: Bool) {
        lblChapter.text = model.attributes.chapterNameToDisplay
        lblUpdate.text = MDFormatter.dateStringFromNow(
            isoDateString: model.attributes.updatedAt
        )
        if let group = model.scanlationGroup {
            contentView.addSubview(lblGroup)
            lblGroup.text = group.attributes.name
            lblGroup.snp.makeConstraints { make in
                make.centerY.equalTo(lblUpdate)
                make.right.equalToSuperview()
            }
            
            contentView.addSubview(ivGroup)
            ivGroup.snp.makeConstraints { make in
                make.centerY.equalTo(lblUpdate)
                make.width.height.equalTo(18)
                make.right.equalTo(lblGroup.snp.left).offset(-4)
                make.left.greaterThanOrEqualTo(lblUpdate.snp.right).offset(32)
            }
        }
    }
}
