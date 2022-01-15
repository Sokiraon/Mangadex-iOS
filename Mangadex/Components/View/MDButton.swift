//
//  MDButton.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import UIKit
import SwiftTheme

enum MDButtonVariant {
    case text, contained
}

class MDButton: UIButton {
    convenience init(variant: MDButtonVariant) {
        self.init(type: .system)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        switch variant {
        case .text:
            self.theme_tintColor = UIColor.theme_primaryColor
        case .contained:
            self.setTitleColor(.white, for: .normal)
            self.theme_backgroundColor = UIColor.theme_primaryColor
        }
    }
}
