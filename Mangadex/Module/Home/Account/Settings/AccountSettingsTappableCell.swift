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
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didPressView))
        recognizer.minimumPressDuration = 0
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func didSelectCell() {}
    
    @objc private func didPressView(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            backgroundColor = .grayDFDFDF
        } else if recognizer.state == .ended || recognizer.state == .cancelled {
            backgroundColor = .white
        }
        if recognizer.state == .ended {
            didSelectCell()
        }
    }
}
