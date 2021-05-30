//
//  MDRemoteImage.swift
//  Mangadex
//
//  Created by edz on 2021/5/30.
//

import Foundation
import Just
import SwiftyJSON

class MDRemoteImage {
    private static let API_HOST = "https://api.mangadex.org"
    private static let UPLOADS_HOST = "https://uploads.mangadex.org"
    
    static func getCoverUrlById(_ coverId: String, forManga mangaId: String) -> URL? {
        let r = Just.get(API_HOST + "/cover/" + coverId)
        if r.ok {
            let json = JSON(r.json!)
            if let fileName = json["data"]["attributes"]["fileName"].string {
                return URL(string: UPLOADS_HOST + "/covers/" + mangaId + "/" + fileName)
                    
            }
        }
        return URL(string: UPLOADS_HOST)
    }
}
