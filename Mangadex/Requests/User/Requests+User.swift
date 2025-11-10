//
//  Requests+User.swift
//  Mangadex
//
//  Created by John Rion on 7/22/22.
//

import Foundation
import SwiftyJSON

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
        static func getFollowedMangas(params: [String: Any] = [:]) async throws -> MangaCollection {
            let defaultParams: [String: Any] = [
                "includes[]": ["author", "artist", "cover_art"],
                "limit": 20,
            ]
            let newParams = defaultParams + params
            let json = try await Requests.get(
                url: .mainHost("/user/follows/manga"),
                params: newParams,
                authenticated: true
            )
            guard let model = MangaCollection.yy_model(withJSON: json) else {
                throw Errors.IllegalData
            }
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
            let rawJson = try await Requests.get(
                url: .mainHost("/user/follows/manga/feed"),
                params: newParams,
                authenticated: true
            )
            guard let model = ChapterCollection.yy_model(withJSON: rawJson) else {
                throw Errors.IllegalData
            }
            return model
        }
        
        static func isFollowingManga(mangaId: String) async -> Bool {
            do {
                _ = try await Requests.get(url: .mainHost("/user/follows/manga/\(mangaId)"), authenticated: true)
                return true
            } catch {
                return false
            }
        }
        
        static func getMangaRating(for mangaId: String) async throws -> Int {
            let raw = try await Requests.get(
                url: .mainHost("/rating"),
                params: ["manga[]": mangaId],
                authenticated: true
            )
            let json = JSON(raw)
            if let rating = json["ratings"][mangaId]["rating"].int {
                return rating
            } else {
                // Preserve prior behavior: fulfill 0 when missing
                return 0
            }
        }
        
        static func setMangaRating(for mangaId: String, to value: Int) async -> Bool {
            do {
                let url: URL = .mainHost("/rating/\(mangaId)")
                if value == 0 {
                    try await Requests.delete(url: url, authenticated: true)
                } else {
                    try await Requests.post(url: url, data: ["rating": value], authenticated: true)
                }
                return true
            } catch {
                return false
            }
        }
    }
}
