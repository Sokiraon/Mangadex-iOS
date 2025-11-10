//
//  Requests.swift
//  Mangadex
//
//  Created by John Rion on 7/21/22.
//

import Foundation
import Just
import SwiftyJSON

enum HostUrl: String {
    case main = "https://api.mangadex.org"
    case uploads = "https://uploads.mangadex.org"
}

extension URL {
    private static let mainHost = URL(string: "https://api.mangadex.org")!
    private static let uploadsHost = URL(string: "https://uploads.mangadex.org")!
    
    static func mainHost(_ path: String) -> URL {
        mainHost.appending(path: path)
    }
    
    static func uploadsHost(_ path: String) -> URL {
        uploadsHost.appending(path: path)
    }
}

enum Requests {
    enum ErrorCode: Int {
        case BadRequest = 400
        case UnAuthenticated = 401
        case IllegalData = 402
    }
    
    struct ErrorResponse: Error {
        let statusCode: ErrorCode
        let message: String
        
        init(code: ErrorCode, message: String) {
            self.statusCode = code
            self.message = message
        }
    }
    
    enum Errors {
        static let Default = ErrorResponse(
            code: .BadRequest, message: "Network Request Failed"
        )
        static let IllegalData = ErrorResponse(
            code: .IllegalData, message: "Illegal Data"
        )
    }
    
    @discardableResult
    static func get(
        url: URL,
        params: [String: Any] = [:],
        headers: [String: String] = [:],
        authenticated: Bool = false
    ) async throws -> [String: Any] {
        var headers = headers
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Just.get(
                url,
                params: params,
                headers: headers,
                asyncCompletionHandler: { r in
                    if r.ok, let json = r.json as? [String: Any] {
                        continuation.resume(returning: json)
                    } else {
                        continuation.resume(throwing: Errors.Default)
                    }
                }
            )
        }
    }
    
    @discardableResult
    static func post(
        url: URL,
        params: [String: Any] = [:],
        data: Any? = nil,
        authenticated: Bool = false
    ) async throws -> [String: Any] {
        var headers: [String: String] = [:]
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Just.post(
                url,
                params: params,
                json: data,
                headers: headers,
                asyncCompletionHandler: { r in
                    if r.ok, let json = r.json as? [String: Any] {
                        continuation.resume(returning: json)
                    } else {
                        continuation.resume(throwing: Errors.Default)
                    }
                }
            )
        }
    }
    
    @discardableResult
    static func delete(
        url: URL,
        authenticated: Bool = false
    ) async throws -> [String: Any] {
        var headers: [String: String] = [:]
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Just.delete(
                url,
                headers: headers,
                asyncCompletionHandler:  { r in
                    if r.ok, let json = r.json as? [String: Any] {
                        continuation.resume(returning: json)
                    } else {
                        continuation.resume(throwing: Errors.Default)
                    }
                })
        }
    }
}
