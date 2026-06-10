//
//  Requests.swift
//  Mangadex
//
//  Created by John Rion on 7/21/22.
//

import Foundation
import Alamofire

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

    struct DataResponse<T: Decodable & Sendable>: Decodable, Sendable {
        let data: T
    }

    /// Used for Manga.getStatistics and Chapter.getStatistics
    struct StatisticsResponse<T: Decodable & Sendable>: Decodable, Sendable {
        let statistics: [String: T]
    }

    enum RequestPayload {
        case none
        case query([String: Any])
        case json([String: Any?])
    }

    static func request(
        url: URL,
        method: HTTPMethod = .get,
        payload: RequestPayload = .none,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false
    ) async throws {
        var headers = headers
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        let parameters: Parameters?
        let encoding: ParameterEncoding

        switch payload {
        case .none:
            parameters = nil
            encoding = URLEncoding.default
        case .query(let params):
            parameters = params
            encoding = URLEncoding(
                destination: .queryString,
                arrayEncoding: .noBrackets,
                boolEncoding: .literal
            )
        case .json(let body):
            parameters = jsonParameters(from: body)
            encoding = JSONEncoding.default
        }

        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    continuation.resume()
                case .failure:
                    continuation.resume(throwing: Errors.Default)
                }
            }
        }
    }

    @discardableResult
    static func get<T: Decodable & Sendable>(
        url: URL,
        params: [String: Any] = [:],
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        as type: T.Type = T.self
    ) async throws -> T {
        var headers = headers
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers.add(name: "Authorization", value: "Bearer \(token)")
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
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure:
                        continuation.resume(throwing: Errors.Default)
                    }
                }
        }
    }

    @discardableResult
    static func post<T: Decodable & Sendable>(
        url: URL,
        data: [String: Any?]? = nil,
        authenticated: Bool = false,
        as type: T.Type = T.self
    ) async throws -> T {
        var headers: HTTPHeaders = [:]
        if authenticated {
            let token = try await UserManager.shared.getVerifiedToken()
            headers.add(name: "Authorization", value: "Bearer \(token)")
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
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure:
                        continuation.resume(throwing: Errors.Default)
                    }
                }
        }
    }
}
