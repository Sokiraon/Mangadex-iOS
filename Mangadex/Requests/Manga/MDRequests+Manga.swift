//
// Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON
import YYModel

extension MDRequests {
    enum Manga {
        static func query(params: [String: Any] = [:]) -> Promise<[MDMangaItemDataModel]> {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"]
            ]
            let newParams = defaultParams.merging(params) { _, new in
                new
            }
            return Promise { seal in
                firstly {
                    MDRequests.get(path: "/manga", host: .main, params: newParams)
                }
                .done { json in
                    guard let data = json["data"] as? Array<[String: Any]> else {
                        seal.reject(MDRequests.DefaultError)
                        return
                    }
                    let itemModels = NSArray.yy_modelArray(
                        with: MDMangaItemDataModel.classForCoder(),
                        json: data
                    )
                    if let models = itemModels as? [MDMangaItemDataModel] {
                        seal.fulfill(models)
                    }
                }
                .catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func getCoverUrl(coverId: String, mangaId: String) -> Promise<URL> {
            Promise { seal in
                firstly {
                    MDRequests.get(path: "/cover/\(coverId)", host: .main)
                }
                .done { json in
                    let data = JSON(json)
                    if let filename = data["data"]["attributes"]["fileName"].string {
                        let coverUrl = "\(HostUrl.uploads.rawValue)/covers/\(mangaId)/\(filename).256.jpg"
                        seal.fulfill(URL(string: coverUrl)!)
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
                    MDRequests.get(path: "/statistics/manga/\(mangaId)", host: .main)
                }
                .done { json in
                    let data = JSON(json)
                    if let model = MangaStatisticsModel.yy_model(
                        withJSON: data["statistics"][mangaId].rawValue
                    ) {
                        seal.fulfill(model)
                    }
                }
                .catch { error in
                    seal.reject(error)
                }
            }
        }
        
        static func getReadingStatus(mangaId: String) -> Promise<MDMangaReadingStatus> {
            Promise { seal in
                firstly {
                    MDRequests.get(path: "/manga/\(mangaId)/status", requireAuth: true)
                }
                .done { json in
                    let data = JSON(json)
                    if let statusStr = data["status"].string,
                       let status = MDMangaReadingStatus(rawValue: statusStr) {
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
            mangaId: String, newStatus: MDMangaReadingStatus
        ) -> Promise<Bool> {
            let status = newStatus == .null ? nil : newStatus.rawValue
            return Promise { seal in
                firstly {
                    MDRequests.post(
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
                         MDRequests.post(path: "/manga/\(mangaId)/follow", requireAuth: true)
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
                         MDRequests.delete(path: "/manga/\(mangaId)/follow", requireAuth: true)
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
    }
}
