//
//  Requests+Chapter.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
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
            let model = try await Requests.get(
                url: .mainHost("/manga/\(mangaID)/feed"),
                params: params,
                as: ChapterCollection.self
            )
            return model
        }

        static func query(params: [String: Any] = [:]) async throws -> ChapterCollection {
            let defaultParams: [String: Any] = [
                "includes[]": ["scanlation_group", "manga", "user"],
                "translatedLanguage[]": MDLocale.chapterLanguages,
                "contentRating[]": SettingsManager.contentFilter
            ]
            let model = try await Requests.get(
                url: .mainHost("/chapter"),
                params: defaultParams + params,
                as: ChapterCollection.self
            )
            return model
        }

        static func get(id: String) async throws -> ChapterModel {
            let res = try await Requests.get(
                url: .mainHost("/chapter/\(id)"),
                params: [
                    "includes[]": ["scanlation_group", "manga", "user"]
                ],
                as: DataResponse<ChapterModel>.self
            )
            return res.data
        }

        static func getStatistics(id: String) async throws -> ChapterStatisticsModel {
            let res = try await Requests.get(
                url: .mainHost("/statistics/chapter/\(id)"),
                as: StatisticsResponse<ChapterStatisticsModel>.self
            )

            guard let model = res.statistics[id] else {
                throw Errors.IllegalData
            }
            return model
        }

        static func getPageData(chapterId: String) async throws -> ChapterPagesModel {
            let model = try await Requests.get(
                url: .mainHost("/at-home/server/\(chapterId)"),
                as: ChapterPagesModel.self
            )
            return model
        }

        private struct ForumAttributes: Decodable, Sendable {
            let repliesCount: Int
        }

        private struct ForumThreadResponse: Decodable, Sendable {
            let type: String
            let id: Int
            let attributes: ForumAttributes
        }

        static func createForumThread(chapterId: String) async throws -> ChapterStatisticsModel {
            let res = try await Requests.post(
                url: .mainHost("/forums/thread"),
                data: ["type": "chapter", "id": chapterId],
                authenticated: true,
                as: DataResponse<ForumThreadResponse>.self
            )
            let data = res.data
            return ChapterStatisticsModel(
                threadId: data.id,
                repliesCount: data.attributes.repliesCount
            )
        }

        static func markAsRead(mangaID: String, chapterID: String) async throws {
            try await Requests.request(
                url: .mainHost("/manga/\(mangaID)/read"),
                method: .post,
                payload: .json(["chapterIdsRead": [chapterID]]),
                authenticated: true
            )
        }
    }
}
