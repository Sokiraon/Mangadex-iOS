//
//  Requests+Auth.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON
import Combine

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
        
        static func verifyToken(token: String) async throws -> Bool {
            let rawJson = try await get(
                url: .mainHost("/auth/check"),
                headers: ["Authorization": "Bearer \(token)"]
            )
            let json = JSON(rawJson)
            return json["isAuthenticated"].boolValue
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
        
        static func refreshToken(refresh: String) async throws -> Token {
            let rawJson = try await Requests.post(
                url: .mainHost("/auth/refresh"),
                data: ["token": refresh]
            )
            let token = JSON(rawJson)["token"]
            
            guard let session = token["session"].string,
                  let refresh = token["refresh"].string else {
                throw Errors.IllegalData
            }
            
            return Token(session: session, refresh: refresh)
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
