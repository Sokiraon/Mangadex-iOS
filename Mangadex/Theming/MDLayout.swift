//
//  MDLayout.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit

/**
 A helper class for layout-related variables and functions.
 */
class MDLayout {
    
    static var keyWindow: UIWindow {
        UIApplication.shared.windows[0]
    }
    
    static var safeAreaInsets = keyWindow.safeAreaInsets
    static var safeInsetTop = safeAreaInsets.top
    static var safeInsetBottom = safeAreaInsets.bottom
    static var adjustedSafeInsetBottom = max(safeInsetBottom, 16)
    
    static var isNotchScreen = safeInsetBottom > 0
    
    static var scale = keyWindow.screen.scale
    static var nativeScale = keyWindow.screen.nativeScale
    static var native1px = 1.0 / nativeScale
    
    static var screenSize = keyWindow.bounds.size
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
