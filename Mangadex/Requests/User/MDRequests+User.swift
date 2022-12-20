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
        static func getFollowedMangas(params: [String: Any] = [:]) -> Promise<[MDMangaItemDataModel]> {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"]
            ]
            let newParams = defaultParams.merging(params) { _, new in
                new
            }
            return Promise { seal in
                firstly {
                    MDRequests.get(path: "/user/follows/manga", params: newParams, requireAuth: true)
                }.done { json in
                    guard let data = json["data"] as? Array<[String: Any]> else {
                        seal.reject(MDRequests.ErrorResponse())
                        return
                    }
                    let mangaList = NSArray.yy_modelArray(with: MDMangaItemDataModel.classForCoder(), json: data)
                    if let models = mangaList as? [MDMangaItemDataModel] {
                        seal.fulfill(models)
                    }
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
