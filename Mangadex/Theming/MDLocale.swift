//
// Created by John Rion on 2021/7/11.
//

import Foundation

class MDLocale {
    static let defaultLocale = "en"
    
    static let languages = [
        "English", "日本語", "简体中文", "正體中文"
    ]
    
    static let availableLanguages = [
        "简体中文": "zh",
        "正體中文": "zh-hk", // For Mangadex, there are no zh-tw translations available.
        "English": "en",
        "日本語": "jp"
    ]
    
    static let availableRegions = [
        "简体中文": "CN",
        "正體中文": "HK/TW",
        "English": "GB/US",
        "日本語": "JP",
    ]
    
    static var currentMangaLanguage: String {
        availableLanguages[languages[MDSettingsManager.mangaLangIndex]]!
    }
    
    static func mangadexLocale() -> String {
        if (Locale.current.languageCode == "zh") {
            if (Locale.current.regionCode == "CN") {
                return "zh"
            } else {
                return "zh-hk"
            }
        } else {
            return Locale.current.languageCode ?? "en"
        }
    }
    
    static func propertySafeLocale() -> String {
        let locale = mangadexLocale()
        if (locale.count > 2) {
            let parts = locale.split(separator: "-") as? [String]
            if ((parts?.count)! >= 2) {
                return parts![0] + parts![1].capitalized
            }
        }
        return locale
    }
}
