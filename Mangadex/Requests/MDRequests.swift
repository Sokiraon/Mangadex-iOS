//
//  MDRequests.swift
//  Mangadex
//
//  Created by John Rion on 7/21/22.
//

import Foundation
import Just
import SwiftyJSON
import PromiseKit

enum HostUrl: String {
    case main = "https://api.mangadex.org"
    case uploads = "https://uploads.mangadex.org"
}

enum MDRequests {
    enum ErrorCode: Int {
        case Default = 400
        case UnAuthenticated = 401
    }
    
    struct ErrorResponse: Error {
        let code: ErrorCode
        let message: String
        
        init() {
            self.code = .Default
            self.message = "Network Request Failed"
        }
        
        init(code: ErrorCode, message: String) {
            self.code = code
            self.message = message
        }
    }
    
    static let DefaultError = ErrorResponse()
    
    static func get(
        path: String,
        host: HostUrl,
        params: [String: Any] = [:],
        auth: Bool = false
    ) -> Promise<[String: Any]> {
        if auth {
            return Promise { seal in
                firstly {
                    MDUserManager.getInstance().getValidatedToken()
                }.done { token in
                    Just.get(host.rawValue + path,
                             params: params,
                             headers: ["Authorization": "Bearer \(token)"],
                             asyncCompletionHandler:  { r in
                        if r.ok, let json = r.json as? [String: Any] {
                            seal.fulfill(json)
                        } else {
                            seal.reject(ErrorResponse())
                        }
                    })
                }.catch { error in
                    seal.reject(error)
                }
            }
        } else {
            return Promise { seal in
                Just.get(host.rawValue + path, params: params, asyncCompletionHandler:  { r in
                    if r.ok, let json = r.json as? [String: Any] {
                        seal.fulfill(json)
                    } else {
                        seal.reject(ErrorResponse())
                    }
                })
            }
        }
    }
    
    static func post(path: String, host: HostUrl, data: Any) -> Promise<[String: Any]> {
        return Promise { seal in
            Just.post(host.rawValue + path, json: data, asyncCompletionHandler:  { r in
                if r.ok, let json = r.json as? [String: Any] {
                    seal.fulfill(json)
                } else {
                    seal.reject(ErrorResponse())
                }
            })
        }
    }
}
