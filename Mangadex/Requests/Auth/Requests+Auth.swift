//
//  Requests+Auth.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON

extension Requests {
    enum Auth {
        struct Token {
            let session: String
            let refresh: String
        }
        
        static func login(username: String, password: String) -> Promise<Token> {
            Promise { seal in
                firstly {
                    Requests.post(
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
                        seal.fulfill(Token(session: session, refresh: refresh))
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func verifyToken(token: String) -> Promise<Bool> {
            Promise { seal in
                firstly {
                    Requests.get(
                        path: "/auth/check",
                        host: .main,
                        headers: ["Authorization": "Bearer \(token)"]
                    )
                }.done { json in
                    let json = JSON(json)
                    if json["isAuthenticated"].boolValue {
                        seal.fulfill(true)
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func refreshToken(refresh: String) -> Promise<Token> {
            Promise { seal in
                firstly {
                    Requests.post(
                        path: "/auth/refresh",
                        host: .main,
                        data: ["token": refresh]
                    )
                }.done { json in
                    let token = JSON(json)["token"]
                    if let session = token["session"].string,
                       let refresh = token["refresh"].string {
                        seal.fulfill(Token(session: session, refresh: refresh))
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
