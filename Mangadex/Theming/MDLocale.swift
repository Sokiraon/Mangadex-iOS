//
// Created by John Rion on 2021/7/11.
//

import Foundation

class MDLocale {
    
    static let defaultLanguages = ["en"]
    
    static let availableLanguages = [
        "en", "ja", "ko", "zh", "zh-hk",
        "hi", "es", "es-la", "fr", "ar",
        "bn", "ru", "pt", "pt-br", "de",
        "tr", "vi", "it", "th", "uk",
    ]
    
    static let languageToCountryCode = [
        "pt": "PT",
        "pt-br": "BR",
        "en": "GB",
        "ja": "JP",
        "zh": "CN",
        "zh-hk": "HK",
        "uk": "UA",     // Ukraine
        "es": "ES",
        "es-la": "MX",  // Mexico
        "ar": "SA",
        "fr": "FR",
        "vi": "VN",
        "it": "IT",
        "de": "DE",
        "ru": "RU",
        "hi": "IN",
        "bn": "BD",
        "tr": "TR",
        "ko": "KR",
        "th": "TH",
    ]
    
    static var chapterLanguages: [String] {
        SettingsManager.chapterLanguages
    }
    
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
