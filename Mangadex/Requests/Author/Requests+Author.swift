//
//  Requests+Author.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import PromiseKit
import SwiftyJSON

extension Requests {
    enum Author {
        static func get(id: String) -> Promise<MangaAuthorModel> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/author/\(id)")
                }.done { json in
                    let json = JSON(json)
                    if let model = MangaAuthorModel.yy_model(withJSON: json["data"].rawValue) {
                        seal.fulfill(model)
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func query(params: [String: Any] = [:]) -> Promise<MangaAuthorCollection> {
            let defaultParams: [String: Any] = [ "limit": 20 ]
            let params = defaultParams + params
            return Promise { seal in
                firstly {
                    Requests.get(path: "/author", params: params)
                }.done { json in
                    guard let model = MangaAuthorCollection.yy_model(withJSON: json) else {
                        seal.reject(Errors.IllegalData)
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
