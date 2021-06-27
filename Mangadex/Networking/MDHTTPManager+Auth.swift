//
//  MDHTTPManager+Auth.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import SwiftyJSON

extension MDHTTPManager {
    func loginWithUsername(_ username: String,
                           andPassword password: String,
                           onSuccess success: @escaping (_ session: String, _ refresh: String) -> Void,
                           onError error: @escaping () -> Void) {
        self.post("/auth/login",
                  ofType: .HostTypeApi,
                  withJson: ["username": username, "password": password]) { json in
            let json = JSON(json)
            if let session = json["token"]["session"].string,
               let refresh = json["token"]["refresh"].string {
                success(session, refresh)
            }
            else {
                error()
            }
        } onError: {
            error()
        }
    }
    
    func checkToken(_ token: String,
                    onSuccess success: @escaping () -> Void,
                    onError error: @escaping () -> Void) {
        self.get("/auth/check",
                 ofType: .HostTypeApi,
                 withParams: ["Authorization": "Bearer \(token)"]) { json in
            if (json["isAuthenticated"] as! Bool == true) {
                success()
            }
            error()
        } onError: {
            error()
        }
    }
    
    func refreshToken(_ refresh: String,
                      onSuccess success: @escaping (_ session: String, _ token: String) -> Void,
                      onError error: @escaping () -> Void) {
        self.post("/auth/refresh",
                  ofType: .HostTypeApi,
                  withJson: ["token": refresh]) { json in
            let token = json["token"] as! [String: Any]
            if let session = token["session"] as? String,
               let refresh = token["refresh"] as? String {
                success(session, refresh)
            }
            else {
                error()
            }
        } onError: {
            error()
        }

    }
}
