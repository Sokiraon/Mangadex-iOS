//
//  MDRequests+Author.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import PromiseKit
import SwiftyJSON

extension MDRequests {
    enum Author {
        static func get(id: String) -> Promise<MDMangaAuthor> {
            Promise { seal in
                firstly {
                    MDRequests.get(path: "/author/\(id)")
                }.done { json in
                    let json = JSON(json)
                    guard let model = MDMangaAuthor.yy_model(withJSON: json["data"].rawValue) else {
                        seal.reject(MDRequests.DefaultError)
                        return
                    }
                    seal.fulfill(model)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
