//
//  Requests+User.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation

extension Requests {

    /// Includes methods that require user authorization.
    enum User {
        /// Get logged User followed Manga list, requires authorization.
        ///
        /// API defination available at:
        /// [Mangadex API](https://api.mangadex.org/docs/docs/user/#get-logged-user-followed-manga-list)
        ///
        /// - Parameter params: Query parameters, **Dict**
        /// - Returns: Promise fulfilled by Array of MangaItem
        static func getFollowedMangas(
            params: [String: Any] = [:]
        ) async throws -> MangaCollection {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"],
                "limit": 20,
            ]
            let newParams = defaultParams + params
            let model = try await Requests.get(
                url: .mainHost("/user/follows/manga"),
                params: newParams,
                authenticated: true,
                as: MangaCollection.self
            )
            return model
        }

        static func getFollowedMangaFeed(params: [String: Any] = [:]) async throws -> ChapterCollection {
            let defaultParams: [String: Any] = [
                "limit": 32,
                "includes[]": ["user", "scanlation_group"],
                "order[readableAt]": "desc",
                "translatedLanguage[]": MDLocale.chapterLanguages
            ]
            let newParams = defaultParams + params
            let model = try await Requests.get(
                url: .mainHost("/user/follows/manga/feed"),
                params: newParams,
                authenticated: true,
                as: ChapterCollection.self
            )
            return model
        }

        static func isFollowingManga(mangaId: String) async -> Bool {
            do {
                try await Requests.request(
                    url: .mainHost("/user/follows/manga/\(mangaId)"),
                    authenticated: true
                )
                return true
            } catch {
                return false
            }
        }

        private struct UserRatingModel: Decodable, Sendable {
            let rating: Int
            let createdAt: String
        }

        private struct UserRatingCollection: Decodable, Sendable {
            let ratings: [String: UserRatingModel]
        }

        static func getMangaRating(for mangaId: String) async -> Int {
            do {
                let data = try await Requests.get(
                    url: .mainHost("/rating"),
                    params: ["manga[]": mangaId],
                    authenticated: true,
                    as: UserRatingCollection.self
                )
                return data.ratings[mangaId]?.rating ?? 0
            } catch {
                return 0
            }
        }

        static func setMangaRating(for mangaId: String, to value: Int) async -> Bool {
            do {
                let url: URL = .mainHost("/rating/\(mangaId)")
                if value == 0 {
                    try await Requests
                        .request(url: url, method: .delete, authenticated: true)
                } else {
                    try await Requests
                        .request(
                            url: url,
                            method: .post,
                            payload: .json(["rating": value]),
                            authenticated: true
                        )
                }
                return true
            } catch {
                return false
            }
        }
    }
}
