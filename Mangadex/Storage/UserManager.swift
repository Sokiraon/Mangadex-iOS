//
//  UserManager.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import Foundation
import SwiftyJSON

actor UserManager {
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
    
    func login(username: String, password: String) async throws {
        let token = try await Requests.Auth.login(username: username, password: password)
        setSession(token, username: username)
        try? MDKeychain.save(
            username: username,
            session: token.session,
            refresh: token.refresh
        )
        Self.logoutAsGuest()
    }

    func login(with credential: Credential) async throws {
        let isValid = try? await Requests.Auth.verifyToken(token: credential.session)
        if isValid == true {
            setSession(
                Requests.Auth.Token(
                    session: credential.session,
                    refresh: credential.refresh
                ),
                username: credential.username
            )
            Self.logoutAsGuest()
            return
        }

        let token = try await Requests.Auth.refreshToken(refresh: credential.refresh)
        setSession(token, username: credential.username)
        try? MDKeychain.save(
            username: credential.username,
            session: token.session,
            refresh: token.refresh
        )
        Self.logoutAsGuest()
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
    
    static func logoutAsGuest() {
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
        setSession(newToken, username: username)
        try? MDKeychain.save(
            username: username,
            session: newToken.session,
            refresh: newToken.refresh
        )
        return newToken.session
    }
    
    func logout() {
        session = ""
        refresh = ""
        username = ""
        Self.logoutAsGuest()
    }

    private func setSession(_ token: Requests.Auth.Token, username: String) {
        self.session = token.session
        self.refresh = token.refresh
        self.username = username
    }
}
