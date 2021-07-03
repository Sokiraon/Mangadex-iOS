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

    static var safeAreaSize = { () -> CGSize in
        let size = UIApplication.shared.windows[0].bounds.size
        let edgeInsets = safeAreaInsets(true)
        return CGSize(width: size.width - edgeInsets.left - edgeInsets.right,
                      height: size.height - edgeInsets.top - edgeInsets.bottom)
    }
    
    static var safeAreaInsets = { (preserveInset: Bool) -> UIEdgeInsets in
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            if (preserveInset) {
                // if is notch screen, return original safeArea
                return window.safeAreaInsets
            } else {
                // else, return zero inset
                return .zero
            }
            
        } else {
            return .zero
        }
    }

    static var safeInsetTop = UIApplication.shared.windows[0].safeAreaInsets.top
    static var safeInsetBottom = UIApplication.shared.windows[0].safeAreaInsets.bottom
    static var isNotchScreen = safeInsetBottom > 0
    
    static var screenSize = UIApplication.shared.windows[0].bounds.size
    static var screenWidth = screenSize.width
    static var screenHeight = screenSize.height
}
