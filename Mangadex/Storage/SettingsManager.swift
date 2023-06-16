//
//  SettingsManager.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/12.
//

import Foundation
import SwiftTheme

class SettingsManager {
    enum Keys: String {
        case themeColorIndex = "com.sokiraon.Mangadex.themeColorIndex"
        case chapterLanguages = "com.sokiraon.Mangadex.chapterLanguages"
        case isDataSaving = "com.sokiraon.Mangadex.isDataSaving"
    }
    
    static var themeColorIndex: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.themeColorIndex.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.themeColorIndex.rawValue)
            ThemeManager.setTheme(index: newValue)
        }
    }
    
    static var chapterLanguages: [String] {
        get {
            UserDefaults.standard.object(forKey: Keys.chapterLanguages.rawValue) as? [String]
            ?? MDLocale.defaultLanguages
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.chapterLanguages.rawValue)
        }
    }
    
    static var isDataSavingMode: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.isDataSaving.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isDataSaving.rawValue)
        }
    }
    
    static func initData() {
        ThemeManager.setTheme(index: themeColorIndex)
    }
}
