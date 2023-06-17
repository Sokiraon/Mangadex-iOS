//
//  AccountSettingsPickerCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/14.
//

import Foundation
import SwiftEntryKit

class AccountSettingsPickerCell: AccountSettingsTappableCell {
    
    private lazy var ivArrow = UIImageView(
        named: "icon_chevron_right", color: .darkerGray565656
    )
    
    init() {
        super.init(frame: .zero)
        
        contentView.addSubview(ivArrow)
        ivArrow.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var popupView: UIView?
    
    override func didSelectCell() {
        guard popupView != nil else {
            return
        }
        var attrs = EKAttributes.centerFloat
        attrs.name = "Settings Popup"
        attrs.displayDuration = .infinity
        attrs.screenInteraction = .dismiss
        attrs.entryInteraction = .forward
        attrs.screenBackground = .color(color: EKColor(UIColor(white: 0.5, alpha: 0.5)))
        attrs.positionConstraints.size = .init(
            width: .constant(value: MDLayout.screenWidth - 30), height: .intrinsic
        )
        attrs.entranceAnimation = .init(
            translate: .init(duration: 0.5, spring: .init(damping: 1, initialVelocity: 0)),
            scale: nil,
            fade: nil
        )
        
        SwiftEntryKit.display(entry: popupView!, using: attrs)
    }
}
