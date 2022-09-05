//
//  MDUserDefaultsManager.swift
//  Mangadex
//
//  Created by John Rion on 2021/7/31.
//

import Foundation

enum UserDefaultsStringValueKey: String {
    case kUserSessionToken, kUserRefreshToken, kUsernameToken
}

enum UserDefaultsIntValueKey: String {
    case kThemeColorIndex, kMangaPrefLang
}

enum UserDefaultsBoolValueKey: String {
    case kUserIsGuest
}

class MDUserDefaultsManager {
    
    static func storeStr(_ value: String, forKey key: UserDefaultsStringValueKey) {
        let prefs = UserDefaults.standard
        prefs.set(value, forKey: key.rawValue)
    }
    
    static func retrieveStr(forKey key: UserDefaultsStringValueKey) -> String? {
        UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    static func storeInt(_ value: Int, forKey key: UserDefaultsIntValueKey) {
        let prefs = UserDefaults.standard
        prefs.set(value, forKey: key.rawValue)
    }
    
    static func retrieveInt(forKey key: UserDefaultsIntValueKey) -> Int {
        UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    static func storeBool(_ value: Bool, forKey key: UserDefaultsBoolValueKey) {
        let prefs = UserDefaults.standard
        prefs.set(value, forKey: key.rawValue)
    }
    
    static func retrieveBool(forKey key: UserDefaultsBoolValueKey) -> Bool {
        UserDefaults.standard.bool(forKey: key.rawValue)
    }
}
