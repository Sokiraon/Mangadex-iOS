//
//  AccountSettingsView.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/24.
//

import Foundation
import UIKit

class AccountSettingsView: UIStackView {
    init(sections: AccountSettingsSection...) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 16
        for section in sections {
            addArrangedSubview(section)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
