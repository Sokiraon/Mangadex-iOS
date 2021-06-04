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
    
    static func getMangaList(offset: Int) -> Array<MangaItem> {
        var result: Array<MangaItem> = []
        let r = Just.get(API_HOST + "/manga", params: ["offset": offset])
        if r.ok {
            let json = JSON(r.json!)
            if let mangaArray = json["results"].array {
                for manga in mangaArray {
                    if let id = manga["data"]["id"].string,
                       let title = manga["data"]["attributes"]["title"]["en"].string,
                       let relationships = manga["relationships"].array {
                        var authorId = "", artistId = "", coverId = ""
                        for relation in relationships {
                            switch relation["type"].string {
                            case "author":
                                authorId = relation["id"].string ?? ""
                                break
                            case "artist":
                                artistId = relation["id"].string ?? ""
                                break
                            case "cover_art":
                                coverId = relation["id"].string ?? ""
                                break
                            default:
                                break
                            }
                        }
                        result.append(MangaItem(id: id, title: title, authorId: authorId, artistId: artistId, coverId: coverId))
                    }
                }
            }
        }
        return result
    }
}
