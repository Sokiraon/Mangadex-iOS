//
//  MDUserDefaultsManager.swift
//  Mangadex
//
//  Created by John Rion on 2021/7/31.
//

import Foundation

enum UserDefaultsKey: String {
    case kUserSessionToken, kUserRefreshToken
}

class MDUserDefaultsManager {
    
    static func storeStr(_ str: String, forKey key: UserDefaultsKey) {
        let prefs = UserDefaults.standard
        prefs.set(str, forKey: key.rawValue)
    }
    
    static func retrieveStr(forKey key: UserDefaultsKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
}
