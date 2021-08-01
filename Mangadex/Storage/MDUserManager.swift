//
//  MDUserManager.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import Foundation
import Just
import SwiftyJSON

class MDUserManager {
    private static let instance = MDUserManager()
    
    static func getInstance() -> MDUserManager {
        return instance
    }
    
    private init() {}
    
    private lazy var _session = MDUserDefaultsManager.retrieveStr(forKey: .kUserSessionToken) ?? ""
    private lazy var _refresh = MDUserDefaultsManager.retrieveStr(forKey: .kUserRefreshToken) ?? ""
    private lazy var _username = MDUserDefaultsManager.retrieveStr(forKey: .kUsernameToken) ?? ""
    
    private var session: String {
        get {
            self._session
        }
        set {
            self._session = newValue
            MDUserDefaultsManager.storeStr(newValue, forKey: .kUserSessionToken)
        }
    }
    private var refresh: String {
        get {
            self._refresh
        }
        set {
            self._refresh = newValue
            MDUserDefaultsManager.storeStr(newValue, forKey: .kUserRefreshToken)
        }
    }
    var username: String {
        get {
            self._username.isEmpty ? "kDefaultUsername".localized() : self._username
        }
        set {
            self._username = newValue
            MDUserDefaultsManager.storeStr(newValue, forKey: .kUsernameToken)
        }
    }
    
    func isLoggedIn() -> Bool {
        !(_session.isEmpty || _refresh.isEmpty || _username.isEmpty)
    }
    
    func loginWithUsername(_ username: String,
                           andPassword password: String,
                           onSuccess success: @escaping () -> Void,
                           onError error: @escaping () -> Void) {
        MDHTTPManager.getInstance()
            .loginWithUsername(username, andPassword: password) { session, refresh in
                self.session = session
                self.refresh = refresh
                self.username = username
                success()
            } onError: {
                error()
            }
    }
    
    func getValidatedToken(onSuccess success: @escaping (_ token: String) -> Void,
                           onError error: @escaping () -> Void) {
        MDHTTPManager.getInstance()
            .checkToken(self.session) {
                success(self.session)
            } onError: {
                MDHTTPManager.getInstance()
                    .refreshToken(self.refresh) { session, refresh in
                        self.session = session
                        self.refresh = refresh
                        success(session)
                    } onError: {
                        error()
                    }
            }
    }
    
    static func logOut(completion: () -> Void) {
        instance.session = ""
        instance.refresh = ""
        instance.username = ""
        completion()
    }
}
