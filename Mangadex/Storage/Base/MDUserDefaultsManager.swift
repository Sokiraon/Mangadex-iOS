//
//  MDUserDefaultsManager.swift
//  Mangadex
//
//  Created by John Rion on 2021/7/31.
//

import Foundation

enum UserDefaultsKey: String {
    case kUserSessionToken, kUserRefreshToken, kUsernameToken
    case kThemeColorIndex, kMangaPrefLang
}

class MDUserDefaultsManager {
    
    static func storeStr(_ str: String, forKey key: UserDefaultsKey) {
        let prefs = UserDefaults.standard
        prefs.set(str, forKey: key.rawValue)
    }
    
    static func retrieveStr(forKey key: UserDefaultsKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    static func storeInt(_ int: Int, forKey key: UserDefaultsKey) {
        let prefs = UserDefaults.standard
        prefs.set(int, forKey: key.rawValue)
    }
    
    static func retrieveInt(forKey key: UserDefaultsKey) -> Int {
        UserDefaults.standard.integer(forKey: key.rawValue)
    }
}
