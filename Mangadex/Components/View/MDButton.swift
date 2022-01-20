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
    case text, contained, outlined
}

class MDButton: UIButton {
    convenience init(variant: MDButtonVariant) {
        self.init(type: .system)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.layer.cornerRadius = 4
        
        switch variant {
        case .text:
            self.theme_tintColor = UIColor.theme_primaryColor
        case .contained:
            self.setTitleColor(.white, for: .normal)
            self.theme_backgroundColor = UIColor.theme_primaryColor
        case .outlined:
            self.backgroundColor = .white
            self.theme_setTitleColor(UIColor.theme_darkColor, forState: .normal)
            self.layer.borderWidth = 1
            self.layer.theme_borderColor = UIColor.theme_primaryCgColor
        }
    }
}
