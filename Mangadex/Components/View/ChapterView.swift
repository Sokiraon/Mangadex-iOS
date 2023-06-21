//
//  ChapterView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/17.
//

import Foundation
import UIKit
import SnapKit

class ChapterView: UIView {
    let flagView = UIImageView()
    let titleLabel = UILabel(fontSize: 16)
    let externIcon = UIImageView()
    let groupIcon = UIImageView(named: "icon_group", color: .secondaryText)
    let groupLabel = UILabel(fontSize: 15, color: .secondaryText)
    let updateLabel = UILabel(fontSize: 15, color: .secondaryText)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(flagView)
        flagView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(24)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.centerY.equalTo(flagView)
            make.left.equalTo(flagView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().inset(8)
        }
        
        addSubview(externIcon)
        externIcon.snp.makeConstraints { make in
            make.centerY.equalTo(flagView)
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        addSubview(groupIcon)
        groupIcon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(4)
            make.size.equalTo(24)
        }
        
        addSubview(updateLabel)
        updateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(groupIcon)
            make.right.equalToSuperview()
        }
        
        addSubview(groupLabel)
        groupLabel.snp.makeConstraints { make in
            make.centerY.equalTo(groupIcon)
            make.left.equalTo(groupIcon.snp.right).offset(8)
            make.right.lessThanOrEqualTo(updateLabel.snp.left).offset(-8)
        }
    }
    
    func setContent(with model: ChapterModel) {
        flagView.image = model.attributes.languageFlag
        titleLabel.text = model.attributes.fullChapterName
        if let group = model.relationships.group {
            groupLabel.text = group.attributes.name
        }
        else if let user = model.relationships.user {
            groupIcon.image = .init(named: "icon_person_outlined")
            groupLabel.text = user.attributes?.username
        }
        updateLabel.text = DateHelper.dateStringFromNow(
            isoDateString: model.attributes.readableAt)
        if model.attributes.externalUrl == nil {
            externIcon.removeFromSuperview()
        } else {
            externIcon.image = .init(named: "icon_open_in_new")
            externIcon.theme_tintColor = UIColor.themeDarkPicker
        }
    }
}
