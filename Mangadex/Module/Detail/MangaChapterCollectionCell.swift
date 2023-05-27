//
//  MangaChapterCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit
import SnapKit

class MangaChapterCollectionCell: UICollectionViewCell {
    
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
    private let vDivider = LineView()
    
    private lazy var ivGroup = UIImageView(named: "icon_group", color: .secondaryText)
    private lazy var lblGroup = UILabel(fontSize: 15, color: .secondaryText)
    
    private lazy var ivOpenInNew = UIImageView(named: "icon_open_in_new", color: .themeDark)
    
    private func setupUI() {
        contentView.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth - 2 * 16)
        }
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        contentView.addSubview(lblChapter)
        lblChapter.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.left.right.equalToSuperview()
        }
        
        contentView.addSubview(lblUpdate)
        lblUpdate.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(lblChapter.snp.bottom).offset(8)
        }
        
        contentView.addSubview(vDivider)
        vDivider.snp.makeConstraints { make in
            make.top.equalTo(lblUpdate.snp.bottom).offset(12)
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func update(with model: MDMangaChapterModel) {
        lblChapter.text = model.attributes.fullChapterName
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
        if model.attributes.externalUrl != nil {
            contentView.addSubview(ivOpenInNew)
            ivOpenInNew.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.width.height.equalTo(20)
            }
            
            lblChapter.snp.remakeConstraints { make in
                make.centerY.equalTo(ivOpenInNew)
                make.top.equalToSuperview().inset(12)
                make.left.equalTo(ivOpenInNew.snp.right).offset(4)
                make.right.equalToSuperview()
            }
        }
    }
}
