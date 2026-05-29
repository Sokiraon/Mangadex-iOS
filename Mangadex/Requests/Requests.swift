//
//  Requests.swift
//  Mangadex
//
//  Created by John Rion on 7/21/22.
//

import Foundation
import Alamofire
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

    private static func jsonParameters(from data: [String: Any?]?) -> Parameters? {
        guard let data else {
            return nil
        }
        return data.mapValues { $0 ?? NSNull() }
    }

    @discardableResult
    static func get(
        url: URL,
        params: [String: Any] = [:],
        headers: HTTPHeaders = [:],
        authenticated: Bool = false
    ) async throws -> [String: Any] {
        var headers = headers
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers["Authorization"] = "Bearer \(token)"
        }
        
        let encoding = URLEncoding(
            destination: .methodDependent,
            arrayEncoding: .noBrackets,
            boolEncoding: .literal
        )

        return try await withCheckedThrowingContinuation { continuation in
            AF
                .request(
                    url,
                    parameters: params,
                    encoding: encoding,
                    headers: headers
                )
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let json = try? JSON(data: data).dictionaryObject else {
                            continuation.resume(throwing: Errors.IllegalData)
                            return
                        }
                        continuation.resume(returning: json)
                    case .failure:
                        continuation.resume(throwing: Errors.Default)
                    }
                }
        }
    }

    @discardableResult
    static func post(
        url: URL,
        data: [String: Any?]? = nil,
        authenticated: Bool = false
    ) async throws -> [String: Any] {
        var headers: HTTPHeaders = [:]
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers["Authorization"] = "Bearer \(token)"
        }

        return try await withCheckedThrowingContinuation { continuation in
            AF
                .request(
                    url,
                    method: .post,
                    parameters: jsonParameters(from: data),
                    encoding: JSONEncoding.default,
                    headers: headers
                )
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let json = try? JSON(data: data).dictionaryObject else {
                            continuation.resume(throwing: Errors.IllegalData)
                            return
                        }
                        continuation.resume(returning: json)
                    case .failure:
                        continuation.resume(throwing: Errors.Default)
                    }
                }
        }
    }

    @discardableResult
    static func delete(
        url: URL,
        authenticated: Bool = false
    ) async throws -> [String: Any] {
        var headers: HTTPHeaders = [:]
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers["Authorization"] = "Bearer \(token)"
        }

        return try await withCheckedThrowingContinuation { continuation in
            AF
                .request(
                    url,
                    method: .delete,
                    encoding: JSONEncoding.default,
                    headers: headers
                )
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let json = try? JSON(data: data).dictionaryObject else {
                            continuation.resume(throwing: Errors.IllegalData)
                            return
                        }
                        continuation.resume(returning: json)
                    case .failure:
                        continuation.resume(throwing: Errors.Default)
                    }
                }
        }
    }
}
