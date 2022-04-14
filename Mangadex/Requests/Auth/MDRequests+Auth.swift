//
//  MDRequests+Auth.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON

extension MDRequests {
    enum Auth {
        struct LoginToken {
            let session: String
            let refresh: String
        }
        
        static func login(username: String, password: String) -> Promise<LoginToken> {
            Promise { seal in
                firstly {
                    MDRequests.post(
                        path: "/auth/login",
                        host: .main,
                        data: [
                            "username": username,
                            "password": password
                        ]
                    )
                }.done { json in
                    let json = JSON(json)
                    if let session = json["token"]["session"].string,
                       let refresh = json["token"]["refresh"].string {
                        seal.fulfill(LoginToken(session: session, refresh: refresh))
                    } else {
                        seal.reject(MDRequests.DefaultError)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func verifyToken(token: String) -> Promise<Bool> {
            Promise { seal in
                firstly {
                    MDRequests.get(
                        path: "/auth/check",
                        host: .main,
                        params: ["Authorization": "Bearer \(token)"]
                    )
                }.done { json in
                    if (json["isAuthenticated"] as? Bool == true) {
                        seal.fulfill(true)
                    } else {
                        seal.reject(MDRequests.DefaultError)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func refreshToken(refresh: String) -> Promise<LoginToken> {
            Promise { seal in
                firstly {
                    MDRequests.post(
                        path: "/auth/refresh",
                        host: .main,
                        data: ["token": refresh]
                    )
                }.done { json in
                    let token = json["token"] as! [String: Any]
                    if let session = token["session"] as? String,
                       let refresh = token["refresh"] as? String {
                        seal.fulfill(LoginToken(session: session, refresh: refresh))
                    } else {
                        seal.reject(MDRequests.DefaultError)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
