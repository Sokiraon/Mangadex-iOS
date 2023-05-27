//
//  AccountSettingsTappableCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/24.
//

import Foundation
import UIKit

class AccountSettingsTappableCell: AccountSettingsCell {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCell)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc internal func didTapCell() {}
}

extension AccountSettingsTappableCell {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .grayDFDFDF
        super.touchesBegan(touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .white
        super.touchesEnded(touches, with: event)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .white
        super.touchesCancelled(touches, with: event)
    }
}
