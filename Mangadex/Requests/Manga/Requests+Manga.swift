//
// Created by John Rion on 7/22/22.
//

import Foundation
import SwiftyJSON
import YYModel

extension Requests {
    enum Manga {
        static func get(id: String) async throws -> MangaModel {
            let json = try await Requests.get(
                url: .mainHost("/manga/\(id)"),
                params: [
                    "includes[]": ["author", "artist", "cover_art"],
                ]
            )
            guard let data = json["data"],
                  let model = MangaModel.yy_model(withJSON: data) else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func query(params: [String: Any] = [:]) async throws -> MangaCollection {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"],
                "limit": 15,
                "contentRating[]": SettingsManager.contentFilter
            ]
            let newParams = defaultParams + params
            let rawJson = try await Requests.get(url: .mainHost("manga"), params: newParams)
            guard let model = MangaCollection.yy_model(withJSON: rawJson) else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func getReadChapters(mangaID: String) async throws -> [String] {
            let rawJson = try await Requests.get(url: .mainHost("/manga/\(mangaID)/read"), authenticated: true)
            let json = JSON(rawJson)
            guard let data = json["data"].arrayObject as? [String] else {
                throw Errors.IllegalData
            }
            return data
        }
        
        static func getCoverUrl(coverId: String, mangaId: String) async throws -> URL {
            let json = try await Requests.get(url: .mainHost("/cover/\(coverId)"))
            let data = JSON(json)
            guard let filename = data["data"]["attributes"]["fileName"].string else {
                throw Errors.IllegalData
            }
            let coverUrl = "\(HostUrl.uploads.rawValue)/covers/\(mangaId)/\(filename).256.jpg"
            guard let url = URL(string: coverUrl) else {
                throw Errors.IllegalData
            }
            return url
        }
        
        static func getStatistics(mangaId: String) async throws -> MangaStatisticsModel {
            let json = try await Requests.get(url: .mainHost("/statistics/manga/\(mangaId)"))
            let data = JSON(json)
            guard let model = MangaStatisticsModel.yy_model(
                withJSON: data["statistics"][mangaId].rawValue
            ) else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func getReadingStatus(mangaId: String) async -> MangaReadingStatus? {
            do {
                let json = try await Requests.get(url: .mainHost("/manga/\(mangaId)/status"), authenticated: true)
                let data = JSON(json)
                if let statusStr = data["status"].string,
                   let status = MangaReadingStatus(rawValue: statusStr) {
                    return status
                } else {
                    return .none
                }
            } catch {
                // Preserve previous behavior: return .null on error
                return .none
            }
        }
        
        /// Update the reading status of a given manga.
        /// Using a `nil` value in the `status` field will remove the status.
        /// 
        /// [Documentation](https://api.mangadex.org/docs/docs/manga/#update-manga-reading-status)
        static func updateReadingStatus(
            mangaId: String, newStatus: MangaReadingStatus?
        ) async throws -> Bool {
            do {
                try await Requests.post(
                    url: .mainHost("/manga/\(mangaId)/status"),
                    data: ["status": newStatus?.rawValue],
                    authenticated: true
                )
                return true
            } catch {
                return false
            }
        }
        
        static func follow(mangaId: String) async throws -> Bool {
            do {
                async let res1 = updateReadingStatus(mangaId: mangaId, newStatus: .reading)
                async let res2 = Requests.post(url: .mainHost("/manga/\(mangaId)/follow"), authenticated: true)
                _ = try await (res1, res2)
                return true
            } catch {
                return false
            }
        }
        
        static func unFollow(mangaId: String) async throws -> Bool {
            do {
                async let res1 = updateReadingStatus(mangaId: mangaId, newStatus: .none)
                async let res2 = Requests.delete(url: .mainHost("/manga/\(mangaId)/follow"), authenticated: true)
                _ = try await (res1, res2)
                return true
            } catch {
                return false
            }
        }
        
        static func getAggregatedChapters(
            mangaId: String,
            groupId: String?,
            language: String
        ) async throws -> MDMangaAggregatedModel {
            var params: [String: Any] = [ "translatedLanguage[]": language ]
            if let groupId {
                params["groups[]"] = groupId
            }
            
            let json = try await Requests.get(url: .mainHost("/manga/\(mangaId)/aggregate"), params: params)
            guard let model = MDMangaAggregatedModel.yy_model(with: json) else {
                throw Errors.IllegalData
            }
            return model
        }
    }
}
