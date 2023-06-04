//
// Created by John Rion on 2021/7/11.
//

import Foundation

class MDLocale {
    static let defaultLocale = "en"
    
    static let languages = [
        "English", "日本語", "正體中文", "简体中文"
    ]
    
    static let availableLanguages = [
        "简体中文": "zh",
        "正體中文": "zh-hk", // For Mangadex, there are no zh-tw translations available.
        "English": "en",
        "日本語": "jp"
    ]
    
    static let availableRegions = [
        "简体中文": "CN",
        "正體中文": "TW",
        "English": "GB",
        "日本語": "JP",
    ]
    
    static var currentMangaLanguage: String {
        availableLanguages[languages[SettingsManager.mangaLangIndex]]!
    }
    
    static let languageToCountryCode = [
        "pt-br": "BR",
        "en": "GB",
        "jp": "JP",
        "zh": "CN",
        "zh-hk": "HK",
        "uk": "UA",     // Ukraine
        "es-la": "MX",  // Mexico
        "fr": "FR",
        "id": "ID",
        "vi": "VN",
        "it": "IT",
        "de": "DE",
        "fa": "IR",     // Farsi
        "th": "TH",
    ]
    
    /// Get current locale, similar to NSLocale.current but slightly modified
    static var current: String {
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
    
    /// The alternative locale to use for Chinese speakers.
    /// For Simplified Chinese, the alternative is Traditional Chinese and vice versa.
    static var alternative: String {
        if current == "zh" {
            return "zh-hk"
        } else if current == "zh-hk" {
            return "zh"
        }
        return current
    }
    
    static var fallback: String {
        "en"
    }
    
    static func propertySafeLocale() -> String {
        if (current == "zh-hk") {
            return "zhHk"
        }
        return current
    }
}
