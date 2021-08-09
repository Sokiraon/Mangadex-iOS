//
//  String+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/9.
//

import Foundation

extension String {
    func guessedLocale() -> String {
        let length = self.utf16.count
        let languageCode = CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRange(location: 0, length: length)) as String? ?? ""
        return Locale(identifier: languageCode).languageCode ?? ""
    }
}
