//
//  MDThemeManager.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit

/**
 Custom class as layout helper
 */
class MDLayout {
    
    static var safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
    static var safeInsetTop = safeAreaInsets.top
    static var safeInsetBottom = safeAreaInsets.bottom
    
    static var isNotchScreen = safeInsetBottom > 0
    
    static var screenSize = UIApplication.shared.windows[0].bounds.size
    static var screenWidth = screenSize.width
    static var screenHeight = screenSize.height
    
    static var safeAreaSize = CGSize(
        width: screenWidth - safeAreaInsets.left - safeAreaInsets.right,
        height: screenHeight - safeAreaInsets.top - safeAreaInsets.bottom
    )
    
    static func vh(_ value: CGFloat) -> CGFloat {
        screenHeight * value / 100
    }
    
    static func vw(_ value: CGFloat) -> CGFloat {
        screenWidth * value / 100
    }
}
