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
        static func getFollowedMangas(params: [String: Any] = [:]) -> Promise<Array<MangaItem>> {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"]
            ]
            let newParams = defaultParams.merging(params) { _, new in
                new
            }
            return Promise { seal in
                firstly {
                    MDRequests.get(path: "/user/follows/manga", params: newParams, auth: true)
                }.done { json in
                    guard let data = json["data"] as? Array<[String: Any]> else {
                        seal.reject(MDRequests.ErrorResponse())
                        return
                    }
                    var result: Array<MangaItem> = []
                    let mangaList = NSArray.yy_modelArray(with: MDMangaItemDataModel.classForCoder(), json: data)
                    for manga in mangaList as! Array<MDMangaItemDataModel> {
                        result.append(MangaItem(model: manga))
                    }
                    seal.fulfill(result)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func checkIfFollowsManga(mangaId: String) -> Promise<Bool> {
            Promise { seal in
                firstly {
                    MDRequests.get(path: "/user/follows/manga/\(mangaId)", auth: true)
                }.done { json in
                    seal.fulfill(true)
                }.catch { error in
                    seal.fulfill(false)
                }
            }
        }
    }
}
