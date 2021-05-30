//
//  Core.swift
//  Mangadex
//
//  Created by edz on 2021/5/15.
//

import Foundation
import Just
import SwiftyJSON

class MangadexAuth {
    private static let instance = MangadexAuth()
    
    static func getInstance() -> MangadexAuth {
        return instance
    }
    
    private init() {}
    
    private let HOST = "https://api.mangadex.org"
    private var session = ""
    private var refresh = ""
    
    func loginWithPassword(username: String, password: String) -> Bool {
        let r = Just.post(HOST + "/auth/login",
                          json: ["username": username, "password": password])
        if r.ok {
            let json = JSON(r.json!)
            if let session = json["token"]["session"].string,
               let refresh = json["token"]["refresh"].string {
                self.session = session
                self.refresh = refresh
            }
            return true
        } else {
            return false
        }
    }
}
