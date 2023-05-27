//
//  AccountSettingsActionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/23.
//

import Foundation
import UIKit
import SnapKit

class AccountSettingsActionCell: AccountSettingsTappableCell {
    
    private var identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didTapCell() {
        delegate?.didSelectCell(self, with: identifier)
    }
}
