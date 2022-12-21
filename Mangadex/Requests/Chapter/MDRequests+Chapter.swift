//
//  MDRequests+Chapter.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON
import YYModel

extension MDRequests {
    enum Chapter {
        enum Order: String {
            case asc = "asc"
            case desc = "desc"
        }
        
        struct MangaChapterList {
            let total: Int
            let data: [MDMangaChapterInfoModel]
        }
        
        /// Get list of chapters for a specific manga.
        ///
        /// API defination available at:
        /// [Mangadex API](https://api.mangadex.org/docs/docs/manga/#manga-feed)
        ///
        /// - Parameters:
        ///   - mangaId: id of manga to retrieve
        ///   - offset: offset of the list
        ///   - locale: filter by a specific language
        ///   - order: chapter order, either ascending or descending
        /// - Returns: Promise fulfilled by MangaChapterList
        static func getListForManga(
            mangaId: String,
            offset: Int,
            locale: String,
            order: Order
        ) -> Promise<MangaChapterList> {
            return Promise { seal in
                firstly {
                    MDRequests.get(path: "/manga/\(mangaId)/feed", host: .main, params: [
                        "offset": offset,
                        "includes[]": [ "scanlation_group", "user" ],
                        "translatedLanguage[]": locale,
                        "order[chapter]": order.rawValue
                    ])
                }
                    .done { json in
                        let json = JSON(json)
                        let total = json["total"].intValue
                        let results = json["data"].arrayObject
                        let models = NSArray.yy_modelArray(
                            with: MDMangaChapterInfoModel.classForCoder(),
                            json: results ?? []
                        )
                        if let data = models as? [MDMangaChapterInfoModel] {
                            seal.fulfill(MangaChapterList(total: total, data: data))
                        } else {
                            seal.reject(MDRequests.DefaultError)
                        }
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            }
        }
        
        static func getPageData(chapterId: String) -> Promise<MDMangaChapterPagesModel> {
            return Promise { seal in
                firstly {
                    MDRequests.get(path: "/at-home/server/\(chapterId)", host: .main)
                }
                    .done { result in
                        let json = JSON(result)
                        if let data = MDMangaChapterPagesModel.yy_model(withJSON: json.rawValue) {
                            seal.fulfill(data)
                        }
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            }
        }
    }
}
