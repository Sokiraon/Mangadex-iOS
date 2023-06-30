//
//  Requests+Chapter.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON
import YYModel

extension Requests {
    enum Chapter {
        enum Order: String {
            case asc = "asc"
            case desc = "desc"
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
        static func getMangaFeed(
            mangaId: String,
            offset: Int,
            order: Order = .desc
        ) -> Promise<ChapterCollection> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/manga/\(mangaId)/feed", host: .main, params: [
                        "offset": offset,
                        "includes[]": [ "scanlation_group", "user", "manga" ],
                        "translatedLanguage[]": MDLocale.chapterLanguages,
                        "order[chapter]": order.rawValue
                    ])
                }
                    .done { json in
                        guard let model = ChapterCollection.yy_model(withJSON: json) else {
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
        
        static func query(params: [String: Any] = [:]) -> Promise<ChapterCollection> {
            let defaultParams: [String: Any] = [
                "includes[]": ["scanlation_group", "manga", "user"],
                "translatedLanguage[]": MDLocale.chapterLanguages,
                "contentRating[]": SettingsManager.contentFilter
            ]
            return Promise { seal in
                firstly {
                    Requests.get(path: "/chapter", params: defaultParams + params)
                }.done { json in
                    guard let collection = ChapterCollection.yy_model(withJSON: json) else {
                        seal.reject(Errors.IllegalData)
                        return
                    }
                    seal.fulfill(collection)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func get(id: String) -> Promise<ChapterModel> {
            Promise { seal in
                firstly {
                    Requests.get(
                        path: "/chapter/\(id)",
                        params: [
                            "includes[]": ["scanlation_group", "manga", "user"]
                        ]
                    )
                }.done { json in
                    if json.contains("data"), let model = ChapterModel.yy_model(withJSON: json["data"]!) {
                        seal.fulfill(model)
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func getStatistics(id: String) -> Promise<ChapterStatisticsModel> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/statistics/chapter/\(id)")
                }.done { json in
                    let json = JSON(json)
                    if let dict = json["statistics"].dictionary?[id]?.dictionaryObject,
                       let model = ChapterStatisticsModel.yy_model(withJSON: dict) {
                        seal.fulfill(model)
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func getPageData(chapterId: String) -> Promise<ChapterPagesModel> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/at-home/server/\(chapterId)")
                }
                    .done { result in
                        let json = JSON(result)
                        if let data = ChapterPagesModel.yy_model(withJSON: json.rawValue) {
                            seal.fulfill(data)
                        } else {
                            seal.reject(Errors.IllegalData)
                        }
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            }
        }
        
        static func createForumThread(chapterId: String) -> Promise<ChapterStatisticsModel> {
            Promise { seal in
                Requests.post(
                    path: "/forums/thread",
                    data: ["type": "chapter", "id": chapterId],
                    requireAuth: true
                ).done { result in
                    let data = JSON(result)["data"]
                    if let id = data["id"].int,
                       let repliesCount = data["attributes"]["repliesCount"].int {
                        seal.fulfill(ChapterStatisticsModel(threadId: id, repliesCount: repliesCount))
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func markAsRead(mangaId: String, chapterId: String) -> Promise<Void> {
            Promise { seal in
                Requests.post(
                    path: "/manga/\(mangaId)/read",
                    data: ["chapterIdsRead": [chapterId]],
                    requireAuth: true
                ).done { _ in
                    seal.fulfill_()
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
