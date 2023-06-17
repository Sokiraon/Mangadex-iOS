//
//  AccountSettingsCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/24.
//

import Foundation
import UIKit
import SnapKit

class AccountSettingsCell: UIView {
    
    internal let contentView = UIView()
    internal let ivIcon = UIImageView().apply { iv in
        iv.tintColor = .darkerGray565656
    }
    internal let vTextStack = UIStackView()
    internal let lblTitle = UILabel(
        fontSize: 15, fontWeight: .medium, color: .black2D2E2F
    )
    internal lazy var lblSubtitle = UILabel(
        fontSize: 11, fontWeight: .medium, color: .darkerGray565656
    )
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(ivIcon)
        ivIcon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.centerY.equalToSuperview()
        }
        
        contentView.addSubview(vTextStack)
        vTextStack.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(24)
            make.left.equalTo(ivIcon.snp.right).offset(10)
            make.top.bottom.equalToSuperview()
        }
        
        vTextStack.axis = .vertical
        vTextStack.spacing = 3
        vTextStack.distribution = .equalSpacing
        vTextStack.addArrangedSubview(lblTitle)
    }
    
    var icon: UIImage? {
        didSet {
            ivIcon.image = icon
        }
    }
    
    var title: String? {
        didSet {
            lblTitle.text = title
        }
    }
    
    var subTitle: String? {
        didSet {
            lblSubtitle.text = subTitle
            if lblSubtitle.superview == nil {
                vTextStack.addArrangedSubview(lblSubtitle)
            }
        }
    }
    
    var isEnabled = true {
        didSet {
            isUserInteractionEnabled = isEnabled
            if isEnabled {
                ivIcon.tintColor = .darkerGray565656
                lblTitle.textColor = .black2D2E2F
                lblSubtitle.textColor = .darkerGray565656
            } else {
                ivIcon.tintColor = .lightGray
                lblTitle.textColor = .lightGray
                lblSubtitle.textColor = .lightGray
            }
        }
    }
}
