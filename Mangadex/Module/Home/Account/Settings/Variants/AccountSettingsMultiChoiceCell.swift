//
//  AccountSettingsMultiChoiceCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/15.
//

import Foundation
import UIKit
import SwiftEntryKit

class AccountSettingsMultiChoiceCell: AccountSettingsTappableCell {
    
    private let arrowView = UIImageView(
        named: "icon_chevron_right", color: .darkerGray565656)
    
    init() {
        super.init(frame: .zero)
        
        contentView.addSubview(arrowView)
        arrowView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var popupTitle = ""
    var keys = [String]()
    var selectedKeysProvider: () -> Set<String> = { [] }
    var choiceItemUpdater: (_ cell: UICollectionViewListCell, _ indexPath: IndexPath, _ key: String) -> Void
        = { _, _, _ in }
    var onSubmit: (_ selectedKeys: Set<String>) -> Void = { _ in }
    
    override func didSelectCell() {
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
        
        let view = AccountSettingsMultiChoiceView()
        view.delegate = self
        SwiftEntryKit.display(entry: view, using: attrs)
    }
}
