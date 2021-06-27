//
//  MDUser.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import Foundation
import Just
import SwiftyJSON

class MDUser {
    private static let instance = MDUser()
    
    static func getInstance() -> MDUser {
        return instance
    }
    
    private lazy var session = ""
    private lazy var refresh = ""
    
    func loginWithUsername(_ username: String,
                           andPassword password: String,
                           onSuccess success: @escaping () -> Void,
                           onError error: @escaping () -> Void) {
        MDHTTPManager.getInstance()
            .loginWithUsername(username, andPassword: password) { session, refresh in
                self.session = session
                self.refresh = refresh
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
}
