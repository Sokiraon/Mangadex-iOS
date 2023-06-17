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
    var onSelect: (() -> Void)?
    
    override func didSelectCell() {
        onSelect?()
    }
}
