//
//  MDButton.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/1.
//

import Foundation
import UIKit

enum MDButtonStyle {
    case main, secondary, custom
}

class MDButton: UIButton {
    
    convenience init(style: MDButtonStyle, handler: @escaping () -> Void) {
        self.init()
        
        switch style {
        case .main:
            theme_backgroundColor = MDColor.ThemeColors.tint
            setTitleColor(.white, for: .normal)
            setTitleColor(MDColor.get(.darkGray808080), for: .disabled)
            break
        case .secondary:
            break
        default:
            break
        }
        
        addAction(UIAction(handler: { action in
            handler()
        }), for: .touchUpInside)
    }
}
