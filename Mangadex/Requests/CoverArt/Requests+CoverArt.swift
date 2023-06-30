//
//  Requests+CoverArt.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/29.
//

import Foundation
import PromiseKit

extension Requests {
    enum CoverArt {
        static func getMangaCoverList(mangaId: String) -> Promise<CoverArtCollection> {
            Promise { seal in
                firstly {
                    Requests.get(
                        path: "/cover",
                        params: [
                            "order[volume]": "asc",
                            "manga[]": mangaId,
                            "limit": 100
                        ]
                    )
                }.done { json in
                    guard let collection = CoverArtCollection.yy_model(withJSON: json) else {
                        return
                    }
                    seal.fulfill(collection)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
