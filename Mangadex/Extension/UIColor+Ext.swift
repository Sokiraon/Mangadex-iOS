//
//  UIColor+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import UIKit
import SwiftTheme

extension UIColor {
    static let darkerGray565656 = colorFromHex("565656")
    static let darkGray808080 = colorFromHex("808080")
    static let grayDFDFDF = colorFromHex("dfdfdf")
    static let lightGrayE5E5E5 = colorFromHex("e5e5e5")
    static let lighterGrayEFEFEF = colorFromHex("efefef")
    static let lightestGrayF5F5F5 = colorFromHex("f5f5f5")
    
    static let black2D2E2F = colorFromHex("2d2e2f")
    
    /** 蔚蓝 */
    static let themeCerulean = colorFromHex("32b0df")
    /** 青绿 */
    static let themeTeal = colorFromHex("4fb3b0")
    /** 珊瑚红 */
    static let themeCoral = colorFromHex("ff7f50")
    
    static let theme_tintColor = ThemeColorPicker(
        colors: themeCerulean, themeTeal, themeCoral
    )
    
    static let themeColors = [themeCerulean, themeTeal, themeCoral]
    
    static var currentTintColor: UIColor { themeColors[MDSettingsManager.themeColorIndex] }
    
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
    
    func inverseColor() -> UIColor {
        var alpha: CGFloat = 1.0

        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }

        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
        }

        var white: CGFloat = 0.0
        if getWhite(&white, alpha: &alpha) {
            return UIColor(white: 1.0 - white, alpha: alpha)
        }

        return self
    }
}
