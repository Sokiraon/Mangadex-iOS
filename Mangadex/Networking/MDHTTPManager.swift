//
//  MDHTTPManager.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import Just
import SwiftyJSON

enum HostType: String {
    case HostTypeApi = "https://api.mangadex.org"
    case HostTypeUploads = "https://uploads.mangadex.org"
}

class MDHTTPManager {
    // singleton
    private static let instance = MDHTTPManager()
    static func getInstance() -> MDHTTPManager {
        return MDHTTPManager()
    }
    
    func get(_ path: String,
             ofType type: HostType,
             withParams params: [String: Any],
             onSuccess success: @escaping (_ r: [String: Any]) -> Void,
             onError error: @escaping () -> Void) {
        Just.get(type.rawValue + path, params: params, asyncCompletionHandler:  { r in
            if (r.ok) {
                success(r.json as! [String: Any])
            } else {
                error()
            }
        })
    }
    
    func get(_ path: String,
             ofType type: HostType,
             withParams params: [String: Any],
             token: String,
             onSuccess success: @escaping (_ r: [String: Any]) -> Void,
             onError error: @escaping () -> Void) {
        Just.get(type.rawValue + path, params: params, headers: ["Authorization": "Bearer \(token)"],
                 asyncCompletionHandler:  { r in
            if (r.ok) {
                success(r.json as! [String: Any])
            } else {
                error()
            }
        })
    }
    
    func post(_ path: String,
              ofType type: HostType,
              withJson json: Any,
              onSuccess success: @escaping (_ r: [String: Any]) -> Void,
              onError error: @escaping () -> Void) {
        Just.post(type.rawValue + path, json: json, asyncCompletionHandler:  { r in
            if (r.ok) {
                success(r.json as! [String: Any])
            } else {
                error()
            }
        })
    }
}