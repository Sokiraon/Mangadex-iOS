//
//  UserManager.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import Foundation
import Just
import SwiftyJSON
import PromiseKit
import Combine

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    private enum Keys: String {
        case session = "com.sokiraon.Mangadex.sessionToken"
        case refresh = "com.sokiraon.Mangadex.refreshToken"
        case username = "com.sokiraon.Mangadex.username"
        case isGuestUser = "com.sokiraon.Mangadex.isGuestUser"
    }
    
    private lazy var _session = UserDefaults.standard.string(forKey: Keys.session.rawValue) ?? ""
    private lazy var _refresh = UserDefaults.standard.string(forKey: Keys.refresh.rawValue) ?? ""
    private lazy var _username = UserDefaults.standard.string(forKey: Keys.username.rawValue) ?? ""
    
    private var session: String {
        get {
            self._session
        }
        set {
            self._session = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.session.rawValue)
        }
    }
    private var refresh: String {
        get {
            self._refresh
        }
        set {
            self._refresh = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.refresh.rawValue)
        }
    }
    var username: String {
        get {
            self._username.isEmpty ? "kDefaultUsername".localized() : self._username
        }
        set {
            self._username = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.username.rawValue)
        }
    }
    
    func login(username: String, password: String) -> Promise<Bool> {
        Promise { seal in
            firstly {
                Requests.Auth.login(username: username, password: password)
            }.done { token in
                self.session = token.session
                self.refresh = token.refresh
                self.username = username
                seal.fulfill(true)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    var userIsLoggedIn: Bool {
        !(_session.isEmpty || _refresh.isEmpty || _username.isEmpty)
    }
    
    var userIsGuest: Bool {
        UserDefaults.standard.bool(forKey: Keys.isGuestUser.rawValue)
    }
    
    func loginAsGuest() {
        UserDefaults.standard.set(true, forKey: Keys.isGuestUser.rawValue)
    }
    
    static func logOutAsGuest() {
        UserDefaults.standard.set(false, forKey: Keys.isGuestUser.rawValue)
    }
    
    /// Determine whether the user should see login (or pre-login) page at launch
    var shouldDisplayLoginAtLaunch: Bool {
        !(userIsLoggedIn || userIsGuest)
    }
    
    func getVerifiedToken() async throws -> String {
        let isValid = try? await Requests.Auth.verifyToken(token: self.session)
        if isValid == true {
            return self.session
        }
        let newToken = try await Requests.Auth.refreshToken(refresh: self.refresh)
        self.session = newToken.session
        self.refresh = newToken.refresh
        return newToken.session
    }
    
    func getValidatedToken() -> Promise<String> {
        Promise { seal in
            // verify token
            firstly {
                Requests.Auth.verifyToken(token: self.session)
            }.done { res in
                seal.fulfill(self.session)
            }.catch { error in
                // if verification failed, try to refresh token
                firstly {
                    Requests.Auth.refreshToken(refresh: self.refresh)
                }.done { token in
                    self.session = token.session
                    self.refresh = token.refresh
                    seal.fulfill(self.session)
                }.catch { error in
                    // if refresh failed, throw an Error
                    seal.reject(Requests.ErrorResponse(code: .UnAuthenticated, message: "Authentication Expired"))
                }
            }
        }
    }
    
    static func logOutAsUser() {
        shared.session = ""
        shared.refresh = ""
        shared.username = ""
    }
}
