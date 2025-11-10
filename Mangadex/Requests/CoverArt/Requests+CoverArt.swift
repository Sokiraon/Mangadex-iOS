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
            let json = try await Requests.get(
                url: .mainHost("/cover"),
                params: [
                    "order[volume]": "asc",
                    "manga[]": mangaId,
                    "limit": 100
                ]
            )
            guard let collection = CoverArtCollection.yy_model(withJSON: json) else {
                throw Errors.IllegalData
            }
            return collection
        }
    }
}
