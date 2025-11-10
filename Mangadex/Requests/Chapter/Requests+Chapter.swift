//
//  Requests+Chapter.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import SwiftyJSON
import YYModel
import Combine

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
        /// - Returns: ChapterCollection
        static func getMangaFeed(
            mangaID: String,
            offset: Int = 0,
            order: Order = .desc
        ) async throws -> ChapterCollection {
            let params: [String: Any] = [
                "offset": offset,
                "includes[]": [ "scanlation_group", "user", "manga" ],
                "translatedLanguage[]": MDLocale.chapterLanguages,
                "order[chapter]": order.rawValue
            ]
            let rawJson = try await Requests.get(url: .mainHost("/manga/\(mangaID)/feed"), params: params)
            guard let model = ChapterCollection.yy_model(withJSON: rawJson) else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func query(params: [String: Any] = [:]) async throws -> ChapterCollection {
            let defaultParams: [String: Any] = [
                "includes[]": ["scanlation_group", "manga", "user"],
                "translatedLanguage[]": MDLocale.chapterLanguages,
                "contentRating[]": SettingsManager.contentFilter
            ]
            let res = try await Requests.get(url: .mainHost("/chapter"), params: defaultParams + params)
            guard let collection = ChapterCollection.yy_model(withJSON: res) else {
                throw Errors.IllegalData
            }
            return collection
        }
        
        static func get(id: String) async throws -> ChapterModel {
            let res = try await Requests.get(
                url: .mainHost("/chapter/\(id)"),
                params: [
                    "includes[]": ["scanlation_group", "manga", "user"]
                ]
            )
            guard
                res.contains("data"),
                let model = ChapterModel.yy_model(withJSON: res["data"]!)
            else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func getStatistics(id: String) async throws -> ChapterStatisticsModel {
            let res = try await Requests.get(url: .mainHost("/statistics/chapter/\(id)"))
            let json = JSON(res)
            guard
                let dict = json["statistics"].dictionary?[id]?.dictionaryObject,
                let model = ChapterStatisticsModel.yy_model(withJSON: dict)
            else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func getPageData(chapterId: String) async throws -> ChapterPagesModel {
            let raw = try await Requests.get(url: .mainHost("/at-home/server/\(chapterId)"))
            let json = JSON(raw)
            guard let model = ChapterPagesModel.yy_model(withJSON: json.rawValue) else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func createForumThread(chapterId: String) async throws -> ChapterStatisticsModel {
            let res = try await Requests.post(
                url: .mainHost("/forums/thread"),
                data: ["type": "chapter", "id": chapterId],
                authenticated: true
            )
            let data = JSON(res)["data"]
            if
                let id = data["id"].int,
                let repliesCount = data["attributes"]["repliesCount"].int
            {
                return ChapterStatisticsModel(threadId: id, repliesCount: repliesCount)
            } else {
                throw Errors.IllegalData
            }
        }
        
        static func markAsRead(mangaID: String, chapterID: String) async throws {
            try await Requests.post(
                url: .mainHost("/manga/\(mangaID)/read"),
                data: ["chapterIdsRead": [chapterID]],
                authenticated: true
            )
        }
    }
}
