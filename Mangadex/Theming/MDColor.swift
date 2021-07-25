//
//  MDColor.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

enum Colors: String {
    case grayDFDFDF = "dfdfdf"
    case lightGrayE5E5E5 = "e5e5e5"
    case lighterGrayF5F5F5 = "f5f5f5"
    
    // for text use only
    case black2D2E2F = "2d2e2f"
    case darkerGray565656 = "565656"
    case darkGray808080 = "808080"
    
    // theme colors
    case mainBlue = "30A9DE"
    case mainGreen = "3D7979"
    case lightOrange = "fdc23e"
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
}
