//
//  MDUserManager.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import Foundation
import Just
import SwiftyJSON
import PromiseKit

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
    
    func login(username: String, password: String) -> Promise<Bool> {
        Promise { seal in
            firstly {
                MDRequests.Auth.login(username: username, password: password)
            }.done { loginToken in
                self.session = loginToken.session
                self.refresh = loginToken.refresh
                self.username = username
                seal.fulfill(true)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getValidatedToken() -> Promise<String> {
        Promise { seal in
            // verify token
            firstly {
                MDRequests.Auth.verifyToken(token: self.session)
            }.done { res in
                seal.fulfill(self.session)
            }.catch { error in
                // if verification failed, try to refresh token
                firstly {
                    MDRequests.Auth.refreshToken(refresh: self.refresh)
                }.done { loginToken in
                    self.session = loginToken.session
                    self.refresh = loginToken.refresh
                    seal.fulfill(self.session)
                }.catch { error in
                    // if refresh failed, throw an Error
                    seal.reject(MDRequests.ErrorResponse(code: .UnAuthenticated, message: "Authentication Expired"))
                }
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
