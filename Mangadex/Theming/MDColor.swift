//
//  MDColor.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit
import SwiftTheme

enum Colors: String {
    // for background
    case grayDFDFDF = "dfdfdf"
    case lightGrayE5E5E5 = "e5e5e5"
    case lighterGrayF5F5F5 = "f5f5f5"
    
    // for text use only
    case black2D2E2F = "2d2e2f"
    case black323232 = "323232"
    case darkerGray565656 = "565656"
    case darkGray808080 = "808080"
    
    case white = "ffffff"
    
    /** 蔚蓝 */
    case cerulean = "#32B0DF"
    /** 青绿 */
    case teal = "#4FB3B0"
    /** 珊瑚红 */
    case coral = "#FF7F50"
}

enum MDThemeColors: String, CaseIterable {
    /** 蔚蓝 */
    case cerulean = "#32B0DF"
    /** 青绿 */
    case teal = "#4FB3B0"
    /** 珊瑚红 */
    case coral = "#FF7F50"
}

struct ThemeColorPickers {
    let tint: ThemeColorPicker
}

class MDColor {
    static func colorFromHex(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func get(_ color: Colors) -> UIColor {
        colorFromHex(color.rawValue)
    }
    
    static var ThemeColors: ThemeColorPickers = ThemeColorPickers(
        tint: [
            MDThemeColors.cerulean.rawValue,
            MDThemeColors.teal.rawValue,
            MDThemeColors.coral.rawValue,
        ]
    )
    
    static var currentTintColor: UIColor {
        get {
            return self.get([
                Colors.cerulean,
                Colors.teal,
                Colors.coral,
            ][ThemeManager.currentThemeIndex])
        }
    }
}
