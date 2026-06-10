//
//  Requests+Auth.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation

extension Requests {
    enum Auth {
        struct Token: Decodable, Sendable {
            let session: String
            let refresh: String
        }

        private struct TokenResponse: Decodable, Sendable {
            let token: Token
        }

        static func login(username: String, password: String) async throws -> Token {
            let res = try await Requests.post(
                url: .mainHost("/auth/login"),
                data: [
                    "username": username,
                    "password": password
                ],
                as: TokenResponse.self
            )
            return res.token
        }

        private struct CheckTokenResponse: Decodable, Sendable {
            let isAuthenticated: Bool
        }

        static func checkToken(token: String) async throws -> Bool {
            let res = try await get(
                url: .mainHost("/auth/check"),
                headers: ["Authorization": "Bearer \(token)"],
                as: CheckTokenResponse.self
            )
            return res.isAuthenticated
        }

        static func refreshToken(refresh: String) async throws -> Token {
            let res = try await Requests.post(
                url: .mainHost("/auth/refresh"),
                data: ["token": refresh],
                as: TokenResponse.self
            )
            return res.token
        }
    }
}
