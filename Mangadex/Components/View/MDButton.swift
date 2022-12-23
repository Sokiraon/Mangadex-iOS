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
            self.theme_tintColor = UIColor.themePrimaryPicker
        case .contained:
            self.setTitleColor(.white, for: .normal)
            self.theme_backgroundColor = UIColor.themePrimaryPicker
        case .outlined:
            self.backgroundColor = .white
            self.theme_setTitleColor(UIColor.themeDarkPicker, forState: .normal)
            self.layer.borderWidth = 2
            self.layer.theme_borderColor = UIColor.themePrimaryCgPicker
        }
    }
}
