//
//  Requests+CoverArt.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/29.
//

import Foundation

extension Requests {
    enum CoverArt {
        static func getMangaCoverList(mangaId: String) async throws -> CoverArtCollection {
            let model = try await Requests.get(
                url: .mainHost("/cover"),
                params: [
                    "order[volume]": "asc",
                    "manga[]": mangaId,
                    "limit": 100
                ],
                as: CoverArtCollection.self
            )

            return model
        }
    }
}
