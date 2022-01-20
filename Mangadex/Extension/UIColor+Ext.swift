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
    static let darkerGray565656 = fromHex("565656")
    static let darkGray808080 = fromHex("808080")
    static let grayDFDFDF = fromHex("dfdfdf")
    static let lightGrayE5E5E5 = fromHex("e5e5e5")
    static let lighterGrayEFEFEF = fromHex("efefef")
    static let lightestGrayF5F5F5 = fromHex("f5f5f5")
    
    static let black2D2E2F = fromHex("2d2e2f")
    
    /** 蔚蓝 */
    static let cerulean400 = fromHex("32b0df")
    static let cerulean700 = fromHex("0084ba")
    static let cerulean50 = fromHex("e1f4fa")
    /** 青绿 */
    static let teal300 = fromHex("4fb3b0")
    static let teal600 = fromHex("09867f")
    static let teal50 = fromHex("e0f1f2")
    /** 珊瑚红 */
    static let coral400 = fromHex("ff7f50")
    static let coral800 = fromHex("d85627")
    static let coral50 = fromHex("faebe9")
    
    static let theme_primaryColor = ThemeColorPicker(
        colors: cerulean400, teal300, coral400
    )
    static let theme_darkColor = ThemeColorPicker(
        colors: cerulean700, teal600, coral800
    )
    static let theme_primaryCgColor = ThemeCGColorPicker(
        colors: cerulean400.cgColor, teal300.cgColor, coral400.cgColor
    )
    static let theme_lightColor = ThemeColorPicker(colors: cerulean50, teal50, coral50)
    
    static let primaryColors = [cerulean400, teal300, coral400]
    static let lightColors = [cerulean50, teal50, cerulean50]
    
    static var primaryColor: UIColor { primaryColors[MDSettingsManager.themeColorIndex] }
    static var lightColor: UIColor { lightColors[MDSettingsManager.themeColorIndex] }
    
    static func fromHex(_ hex: String) -> UIColor {
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
            alpha: 1
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
