//
// Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON
import YYModel

extension Requests {
    enum Manga {
        static func get(id: String) -> Promise<MangaModel> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/manga/\(id)",
                                 params: [
                                    "includes[]": ["author", "artist", "cover_art"],
                                 ])
                }.done { json in
                    guard let data = json["data"], let model = MangaModel.yy_model(withJSON: data) else {
                        seal.reject(Errors.IllegalData)
                        return
                    }
                    seal.fulfill(model)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func query(params: [String: Any] = [:]) -> Promise<MangaCollection> {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"],
                "limit": 15,
                "contentRating[]": SettingsManager.contentFilter
            ]
            let newParams = defaultParams + params
            return Promise { seal in
                firstly {
                    Requests.get(path: "/manga", host: .main, params: newParams)
                }
                .done { json in
                    guard let model = MangaCollection.yy_model(withJSON: json) else {
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
        
        static func getCoverUrl(coverId: String, mangaId: String) -> Promise<URL> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/cover/\(coverId)", host: .main)
                }
                .done { json in
                    let data = JSON(json)
                    if let filename = data["data"]["attributes"]["fileName"].string {
                        let coverUrl = "\(HostUrl.uploads.rawValue)/covers/\(mangaId)/\(filename).256.jpg"
                        seal.fulfill(URL(string: coverUrl)!)
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }
                .catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func getStatistics(mangaId: String) -> Promise<MangaStatisticsModel> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/statistics/manga/\(mangaId)", host: .main)
                }
                .done { json in
                    let data = JSON(json)
                    if let model = MangaStatisticsModel.yy_model(
                        withJSON: data["statistics"][mangaId].rawValue
                    ) {
                        seal.fulfill(model)
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }
                .catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func getReadingStatus(mangaId: String) -> Promise<MangaReadingStatus> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/manga/\(mangaId)/status", requireAuth: true)
                }
                .done { json in
                    let data = JSON(json)
                    if let statusStr = data["status"].string,
                       let status = MangaReadingStatus(rawValue: statusStr) {
                        seal.fulfill(status)
                    } else {
                        seal.fulfill(.null)
                    }
                }
                .catch { error in
                    seal.fulfill(.null)
                }
            }
        }
        
        /// Update the reading status of a given manga.
        /// Using a `nil` value in the `status` field will remove the status.
        /// 
        /// [Documentation](https://api.mangadex.org/docs/docs/manga/#update-manga-reading-status)
        static func updateReadingStatus(
            mangaId: String, newStatus: MangaReadingStatus
        ) -> Promise<Bool> {
            let status = newStatus == .null ? nil : newStatus.rawValue
            return Promise { seal in
                firstly {
                    Requests.post(
                        path: "/manga/\(mangaId)/status",
                        data: ["status": status],
                        requireAuth: true
                    )
                }
                .done { json in
                    seal.fulfill(true)
                }
                .catch { error in
                    seal.fulfill(false)
                }
            }
        }
        
        static func follow(mangaId: String) -> Promise<Bool> {
            Promise { seal in
                firstly {
                    when(fulfilled: updateReadingStatus(mangaId: mangaId, newStatus: .reading),
                         Requests.post(path: "/manga/\(mangaId)/follow", requireAuth: true)
                    )
                }
                .done { _ in
                    seal.fulfill(true)
                }
                .catch { error in
                    seal.fulfill(false)
                }
            }
        }
        
        static func unFollow(mangaId: String) -> Promise<Bool> {
            Promise { seal in
                firstly {
                    when(fulfilled: updateReadingStatus(mangaId: mangaId, newStatus: .null),
                         Requests.delete(path: "/manga/\(mangaId)/follow", requireAuth: true)
                    )
                }
                .done { _ in
                    seal.fulfill(true)
                }
                .catch { error in
                    seal.fulfill(false)
                }
            }
        }
        
        static func getVolumesAndChapters(
            mangaId: String, groupId: String?, language: String
        ) -> Promise<MDMangaAggregatedModel> {
            Promise { seal in
                firstly {
                    Requests.get(
                        path: "/manga/\(mangaId)/aggregate",
                        params: groupId == nil ? [
                            "translatedLanguage[]": language
                        ] : [
                            "groups[]": groupId!,
                            "translatedLanguage[]": language
                        ]
                    )
                }.done { json in
                    if let model = MDMangaAggregatedModel.yy_model(with: json) {
                        seal.fulfill(model)
                    } else {
                        seal.reject(Errors.IllegalData)
                    }
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
