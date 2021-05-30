//
//  MDRemoteText.swift
//  Mangadex
//
//  Created by edz on 2021/5/30.
//

import Foundation
import Just
import SwiftyJSON

class MDRemoteText {
    private static let API_HOST = "https://api.mangadex.org"
    
    static func getAuthorNameById(_ authorId: String) -> String {
        let r = Just.get(API_HOST + "/author/" + authorId)
        if r.ok {
            let json = JSON(r.json!)
            return json["data"]["attributes"]["name"].string!
        }
        return "unknown"
    }
}
