//
//  MDRequests+User.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit

extension MDRequests {
    enum User {
        /// Get logged User followed Manga list, requires authorization.
        ///
        /// API defination available at:
        /// [Mangadex API](https://api.mangadex.org/docs/docs/user/#get-logged-user-followed-manga-list)
        /// 
        /// - Parameter params: Query parameters, **Dict**
        /// - Returns: Promise fulfilled by Array of MangaItem
        static func getFollowedMangas(params: [String: Any] = [:]) -> Promise<MDMangaListDataModel> {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"],
                "limit": 20,
            ]
            let newParams = defaultParams + params
            return Promise { seal in
                firstly {
                    MDRequests.get(path: "/user/follows/manga", params: newParams, requireAuth: true)
                }.done { json in
                    guard let model = MDMangaListDataModel.yy_model(withJSON: json) else {
                        seal.reject(Errors.IllegalData)
                        return
                    }
                    seal.fulfill(model)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func ifFollowsManga(mangaId: String) -> Promise<Bool> {
            Promise { seal in
                firstly {
                    MDRequests.get(path: "/user/follows/manga/\(mangaId)", requireAuth: true)
                }.done { json in
                    seal.fulfill(true)
                }.catch { error in
                    seal.fulfill(false)
                }
            }
        }
    }
}
