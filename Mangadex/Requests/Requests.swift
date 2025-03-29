//
//  Requests.swift
//  Mangadex
//
//  Created by John Rion on 7/21/22.
//

import Foundation
import Just
import Combine
import SwiftyJSON
import PromiseKit

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
    
    static func get(
        path: String,
        host: HostUrl = .main,
        params: [String: Any] = [:],
        headers: [String: String] = [:],
        requireAuth: Bool = false
    ) -> Promise<[String: Any]> {
        let hostUrl = URL(string: host.rawValue)!
        if requireAuth {
            return Promise { seal in
                firstly {
                    UserManager.shared.getValidatedToken()
                }.done { token in
                    let headers = headers + [
                        "Authorization": "Bearer \(token)"
                    ]
                    Just.get(hostUrl.appending(path: path),
                             params: params,
                             headers: headers,
                             asyncCompletionHandler:  { r in
                        if r.ok, let json = r.json as? [String: Any] {
                            seal.fulfill(json)
                        } else {
                            seal.reject(Errors.Default)
                        }
                    })
                }.catch { error in
                    seal.reject(error)
                }
            }
        } else {
            return Promise { seal in
                Just.get(
                    hostUrl.appending(path: path),
                    params: params,
                    headers: headers,
                    asyncCompletionHandler:  { r in
                        if r.ok, let json = r.json as? [String: Any] {
                            seal.fulfill(json)
                        } else {
                            seal.reject(Errors.Default)
                        }
                    })
            }
        }
    }
    
    static func post(
        url: URL,
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
    
    static func post(
        path: String,
        host: HostUrl = .main,
        data: Any? = nil,
        requireAuth: Bool = false
    ) -> Promise<[String: Any]> {
        let hostUrl = URL(string: host.rawValue)!
        if requireAuth {
            return Promise { seal in
                firstly {
                    UserManager.shared.getValidatedToken()
                }.done { token in
                    Just.post(
                        hostUrl.appending(path: path),
                        json: data,
                        headers: ["Authorization": "Bearer \(token)"],
                        asyncCompletionHandler: { r in
                            if r.ok, let json = r.json as? [String: Any] {
                                seal.fulfill(json)
                            } else {
                                seal.reject(Errors.Default)
                            }
                        }
                    )
                }.catch { error in
                    seal.reject(error)
                }
            }
        } else {
            return Promise { seal in
                Just.post(
                    hostUrl.appending(path: path),
                    json: data,
                    asyncCompletionHandler:  { r in
                        if r.ok, let json = r.json as? [String: Any] {
                            seal.fulfill(json)
                        } else {
                            seal.reject(Errors.Default)
                        }
                    })
            }
        }
    }
    
    static func delete(
        path: String,
        host: HostUrl = .main,
        requireAuth: Bool = false
    ) -> Promise<[String: Any]> {
        let hostUrl = URL(string: host.rawValue)!
        if requireAuth {
            return Promise { seal in
                firstly {
                    UserManager.shared.getValidatedToken()
                }.done { token in
                    Just.delete(
                        hostUrl.appending(path: path),
                        headers: ["Authorization": "Bearer \(token)"],
                        asyncCompletionHandler:  { r in
                            if r.ok, let json = r.json as? [String: Any] {
                                seal.fulfill(json)
                            } else {
                                seal.reject(Errors.Default)
                            }
                        })
                }.catch { error in
                    seal.reject(error)
                }
            }
        } else {
            return Promise { seal in
                Just.delete(
                    hostUrl.appending(path: path),
                    asyncCompletionHandler:  { r in
                        if r.ok, let json = r.json as? [String: Any] {
                            seal.fulfill(json)
                        } else {
                            seal.reject(Errors.Default)
                        }
                    })
            }
        }
    }
    
    /// - Returns: A placeholder Promise object that gets fulfilled immediately with the given value.
    static func Placeholder<V>(_ value: V) -> Promise<V> {
        Promise { seal in
            seal.fulfill(value)
        }
    }
}
