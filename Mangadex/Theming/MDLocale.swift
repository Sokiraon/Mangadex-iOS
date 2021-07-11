//
// Created by John Rion on 2021/7/11.
//

import Foundation

class MDLocale {
    static let defaultLocale = "en"
    
    static let availableLanguages = [
        "中文（简体）": "zh",
        "中文（繁體）": "zh-hk", // For Mangadex, there are no zh-TW translations available.
        "English": "en",
        "日本語": "jp"
    ]
    
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
