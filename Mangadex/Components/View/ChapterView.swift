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
    
    private let rowStack = UIStackView()
    private let viewedImageView = UIImageView()
    private let flagView = UIImageView()
    private let titleLabel = UILabel(fontSize: 16)
    private let externIcon = UIImageView()
    private let groupIcon = UIImageView()
    private let groupLabel = UILabel(fontSize: 15, color: .secondaryText)
    private let updateLabel = UILabel(fontSize: 15, color: .secondaryText)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(rowStack)
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 8
        rowStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(8)
        }
        
        rowStack.addArrangedSubview(viewedImageView)
        viewedImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        rowStack.addArrangedSubview(flagView)
        flagView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        rowStack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
        
        rowStack.addArrangedSubview(externIcon)
        externIcon.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        addSubview(groupIcon)
        groupIcon.tintColor = .secondaryText
        groupIcon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(rowStack.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(4)
            make.size.equalTo(20)
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
    
    func setContent(with model: ChapterModel, viewed: Bool? = nil) {
        if let viewed {
            viewedImageView.isHidden = false
            if viewed {
                viewedImageView.image = .init(named: "icon_viewed")
                viewedImageView.tintColor = .lightText
            } else {
                viewedImageView.image = .init(named: "icon_unviewed")
                viewedImageView.tintColor = .secondaryText
            }
        } else {
            viewedImageView.isHidden = true
        }
        flagView.image = model.attributes.languageFlag
        titleLabel.text = model.attributes.fullChapterName
        if let group = model.relationships.group {
            groupIcon.image = .init(named: "icon_group")
            groupLabel.text = group.attributes.name
        } else if let user = model.relationships.user {
            groupIcon.image = .init(named: "icon_person_outlined")
            groupLabel.text = user.attributes?.username
        }
        updateLabel.text = DateHelper.dateStringFromNow(isoDateString: model.attributes.readableAt)
        if model.attributes.externalUrl == nil {
            externIcon.isHidden = true
        } else {
            externIcon.isHidden = false
            externIcon.image = .init(named: "icon_open_in_new")
            externIcon.theme_tintColor = UIColor.themeDarkPicker
        }
    }
}
