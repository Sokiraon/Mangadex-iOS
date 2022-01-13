//
//  MDSettingsManager.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/12.
//

import Foundation
import SwiftTheme

class MDSettingsManager {
    static var themeColorIndex: Int {
        get {
            MDUserDefaultsManager.retrieveInt(forKey: .kThemeColorIndex)
        }
        set {
            MDUserDefaultsManager.storeInt(newValue, forKey: .kThemeColorIndex)
        }
    }
    
    static var mangaLangIndex: Int {
        get {
            MDUserDefaultsManager.retrieveInt(forKey: .kMangaPrefLang)
        }
        set {
            MDUserDefaultsManager.storeInt(newValue, forKey: .kMangaPrefLang)
        }
    }
    
    static func initData() {
        ThemeManager.setTheme(index: themeColorIndex)
    }
}
