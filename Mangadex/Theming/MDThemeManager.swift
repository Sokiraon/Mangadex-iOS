//
//  MDThemeManager.swift
//  Mangadex
//
//  Created by edz on 2021/5/31.
//

import Foundation
import UIKit

enum MDFontSize: CGFloat {
    case MDFontSubtitle = 15.0
    case MDFontTitle = 18.0
}

class MDFonts {
    static let defaultLabelSize = 15.0
    static let defaultTitleSize = 18.0
    
    static func adjustLabelFont(_ label: UILabel, fromSize size: MDFontSize) {
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = (size.rawValue - 2) / size.rawValue
    }
}

class MDColors {
    
}
