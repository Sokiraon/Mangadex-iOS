//
//  MDHTTPManager+Auth.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation

extension MDHTTPManager {
    func loginWithUsername(_ username: String,
                           andPassword password: String,
                           onSuccess success: (_ session: String, _ refresh: String) -> Void,
                           onError error: () -> Void) {
        self.post("/auth/login",
                  ofType: HostType.HostTypeApi,
                  withJson: ["username": username, "password": password]) { json in
            if let session = json["token"]["session"].string,
               let refresh = json["token"]["refresh"].string {
                success(session, refresh)
            }
            error()
        } onError: {
            error()
        }
    }
}
