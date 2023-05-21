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
        case mangaLangIndex = "com.sokiraon.Mangadex.mangaLangIndex"
        case isDataSaving = "com.sokiraon.Mangadex.isDataSaving"
    }
    
    static var themeColorIndex: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.themeColorIndex.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.themeColorIndex.rawValue)
        }
    }
    
    static var mangaLangIndex: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.mangaLangIndex.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.mangaLangIndex.rawValue)
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
