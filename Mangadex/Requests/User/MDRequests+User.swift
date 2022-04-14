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
        /// Get logged User followed Manga feed (Chapter list), requires authorization.
        ///
        /// API defination available at:
        /// [Mangadex API](https://api.mangadex.org/docs/docs/user/#get-logged-user-followed-manga-feed-chapter-list)
        /// 
        /// - Parameter params: Query parameters, **Dict**
        /// - Returns: Promise fulfilled by Array of MangaItem
        static func getFollowedMangas(params: [String: Any]) -> Promise<Array<MangaItem>> {
            return Promise { seal in
                firstly {
                    MDRequests.get(path: "/user/follows/manga", host: .main, params: params, auth: true)
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
    }
}
