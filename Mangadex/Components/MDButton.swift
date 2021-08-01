//
//  MDButton.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/1.
//

import Foundation
import UIKit

enum MDButtonStyle {
    case themed, custom
}

class MDButton: UIButton {
    
    convenience init(style: MDButtonStyle, handler: @escaping () -> Void) {
        self.init()
        
        if (style == .themed) {
            theme_backgroundColor = MDColor.themeColors[.tint]
            setTitleColor(.white, for: .normal)
            setTitleColor(MDColor.get(.darkGray808080), for: .disabled)
        }
        addAction(UIAction(handler: { action in
            handler()
        }), for: .touchUpInside)
    }
}
