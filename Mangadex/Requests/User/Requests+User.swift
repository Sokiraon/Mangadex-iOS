//
//  Requests+User.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit

extension Requests {
    
    /// Includes methods that require user authorization.
    enum User {
        /// Get logged User followed Manga list, requires authorization.
        ///
        /// API defination available at:
        /// [Mangadex API](https://api.mangadex.org/docs/docs/user/#get-logged-user-followed-manga-list)
        /// 
        /// - Parameter params: Query parameters, **Dict**
        /// - Returns: Promise fulfilled by Array of MangaItem
        static func getFollowedMangas(params: [String: Any] = [:]) -> Promise<MangaCollection> {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"],
                "limit": 20,
            ]
            let newParams = defaultParams + params
            return Promise { seal in
                firstly {
                    Requests.get(path: "/user/follows/manga", params: newParams, requireAuth: true)
                }.done { json in
                    guard let model = MangaCollection.yy_model(withJSON: json) else {
                        seal.reject(Errors.IllegalData)
                        return
                    }
                    seal.fulfill(model)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func getFollowedMangaFeed(params: [String: Any] = [:]) -> Promise<MangaFeedModel> {
            let defaultParams: [String: Any] = [
                "includes[]": ["user", "scanlation_group"],
                "order[readableAt]": "desc",
                "translatedLanguage[]": MDLocale.chapterLanguages
            ]
            let newParams = defaultParams + params
            return Promise { seal in
                Requests.get(path: "/user/follows/manga/feed", params: newParams, requireAuth: true)
                    .done { json in
                        guard let model = MangaFeedModel.yy_model(withJSON: json) else {
                            seal.reject(Errors.IllegalData)
                            return
                        }
                        seal.fulfill(model)
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            }
        }
        
        static func ifFollowsManga(mangaId: String) -> Promise<Bool> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/user/follows/manga/\(mangaId)", requireAuth: true)
                }.done { json in
                    seal.fulfill(true)
                }.catch { error in
                    seal.fulfill(false)
                }
            }
        }
    }
}
