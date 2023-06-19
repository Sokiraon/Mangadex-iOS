//
// Created by John Rion on 2021/7/11.
//

import Foundation

class MDLocale {
    
    static let defaultLanguages = ["en"]
    
    static let availableLanguages = [ "en", "ja", "zh", "zh-hk" ]
    
    static let languageToCountryCode = [
//        "pt-br": "BR",
        "en": "GB",
        "ja": "JP",
        "zh": "CN",
        "zh-hk": "HK",
//        "uk": "UA",     // Ukraine
//        "es-la": "MX",  // Mexico
//        "fr": "FR",
//        "id": "ID",
//        "vi": "VN",
//        "it": "IT",
//        "de": "DE",
//        "fa": "IR",     // Farsi
//        "th": "TH",
//        "sq": "AL",     // Albanian
//        "ar": "SA",     // Saudi Arabia
//        "az": "AZ",
//        "bn": "BD",     // Bangladesh
//        "bg": "BG",
//        "my": "MM",
    ]
    
    static let languageToName = [
        "en": "English",
        "ja": "日本語",
        "zh": "中文（简体）",
        "zh-hk": "中文（繁體）"
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
