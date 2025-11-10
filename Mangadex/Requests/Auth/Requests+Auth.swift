//
//  Requests+Auth.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import SwiftyJSON

extension Requests {
    enum Auth {
        struct Token {
            let session: String
            let refresh: String
        }
        
        static func login(username: String, password: String) async throws -> Token {
            let res = try await Requests.post(
                url: .mainHost("/auth/login"),
                data: [
                    "username": username,
                    "password": password
                ]
            )
            let json = JSON(res)
            if let session = json["token"]["session"].string,
               let refresh = json["token"]["refresh"].string {
                return Token(session: session, refresh: refresh)
            } else {
                throw Errors.IllegalData
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
    }
}
