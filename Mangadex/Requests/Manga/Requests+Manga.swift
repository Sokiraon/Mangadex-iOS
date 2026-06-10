//
// Created by John Rion on 7/22/22.
//

import Foundation

extension Requests {
    enum Manga {
        static func get(id: String) async throws -> MangaModel {
            let res = try await Requests.get(
                url: .mainHost("/manga/\(id)"),
                params: [
                    "includes[]": ["author", "artist", "cover_art"],
                ],
                as: DataResponse<MangaModel>.self
            )
            return res.data
        }

        static func query(params: [String: Any] = [:]) async throws -> MangaCollection {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"],
                "limit": 15,
                "contentRating[]": SettingsManager.contentFilter
            ]
            let newParams = defaultParams + params
            let model = try await Requests.get(
                url: .mainHost("manga"),
                params: newParams,
                as: MangaCollection.self
            )
            return model
        }

        static func getReadChapters(mangaID: String) async throws -> [String] {
            let response = try await Requests.get(
                url: .mainHost("/manga/\(mangaID)/read"),
                authenticated: true,
                as: DataResponse<[String]>.self
            )
            return response.data
        }

        static func getStatistics(mangaId: String) async throws -> MangaStatisticsModel {
            let res = try await Requests.get(
                url: .mainHost("/statistics/manga/\(mangaId)"),
                as: StatisticsResponse<MangaStatisticsModel>.self
            )

            guard let model = res.statistics[mangaId] else {
                throw Errors.IllegalData
            }
            return model
        }

        private struct ReadingStatusResponse: Decodable, Sendable {
            let status: String
        }

        static func getReadingStatus(mangaId: String) async -> MangaReadingStatus? {
            do {
                let res = try await Requests.get(
                    url: .mainHost("/manga/\(mangaId)/status"),
                    authenticated: true,
                    as: ReadingStatusResponse.self
                )
                if let status = MangaReadingStatus(rawValue: res.status) {
                    return status
                }
                return .none
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
                try await Requests.request(
                    url: .mainHost("/manga/\(mangaId)/status"),
                    method: .post,
                    payload: .json(["status": newStatus?.rawValue]),
                    authenticated: true
                )
                return true
            } catch {
                return false
            }
        }

        static func follow(mangaId: String) async throws -> Bool {
            do {
                async let res1 = updateReadingStatus(
                    mangaId: mangaId,
                    newStatus: .reading
                )
                async let res2 = Requests.request(
                    url: .mainHost("/manga/\(mangaId)/follow"),
                    method: .post,
                    authenticated: true
                )
                _ = try await (res1, res2)
                return true
            } catch {
                return false
            }
        }

        static func unFollow(mangaId: String) async throws -> Bool {
            do {
                async let res1 = updateReadingStatus(mangaId: mangaId, newStatus: .none)
                async let res2 = Requests.request(
                    url: .mainHost("/manga/\(mangaId)/follow"),
                    method: .delete,
                    authenticated: true
                )
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
        ) async throws -> MangaAggregatedModel {
            var params: [String: Any] = [ "translatedLanguage[]": language ]
            if let groupId {
                params["groups[]"] = groupId
            }

            let model = try await Requests.get(
                url: .mainHost("/manga/\(mangaId)/aggregate"),
                params: params,
                as: MangaAggregatedModel.self
            )
            return model
        }
    }
}
