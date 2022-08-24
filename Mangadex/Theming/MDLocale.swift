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
        // The language that the user set, but not necessarily provided by the App
        let preferredLanguage = NSLocale.preferredLanguages[0]
        if (preferredLanguage.hasPrefix("zh")) {
            if (preferredLanguage.hasPrefix("zh-Hans")) {
                return "zh"
            } else {
                // return zh-hk for both zh-Hant and zh-HK
                return "zh-hk"
            }
        } else {
            // The languageCode is the same as the language that the user set,
            // only when that language is provided by the App
            return Locale.current.languageCode ?? "en"
        }
    }
    
    static func propertySafeLocale() -> String {
        let locale = mangadexLocale()
        if (locale == "zh-hk") {
            return "zhHk"
        }
        return locale
    }
}
