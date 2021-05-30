//
//  MDThemeManager.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit

class MDLayoutHelper {
    static func safeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return UIEdgeInsets(top: window.safeAreaInsets.top, left: window.safeAreaInsets.left,
                                bottom: window.safeAreaInsets.bottom, right: window.safeAreaInsets.right)
            
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    static func safeAreaSize() -> CGSize {
        let size = UIApplication.shared.windows[0].bounds.size
        let edgeInsets = safeAreaInsets()
        return CGSize(width: size.width - edgeInsets.left - edgeInsets.right,
                      height: size.height - edgeInsets.top - edgeInsets.bottom)
    }
}
