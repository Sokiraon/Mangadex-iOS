//
//  MDMangaRelationshipItem.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import YYModel

class MDMangaCoverAttributes: NSObject {
    @objc var fileName: String!
    @objc var createdAt: String!
    @objc var updatedAt: String!
    
    func getCoverUrl(mangaId: String) -> String {
        "\(HostUrl.uploads.rawValue)/covers/\(mangaId)/\(String(describing: fileName))"
    }
}

class MDMangaRelationshipItem: NSObject, YYModel {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: [String: Any]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [
            "attributes": (Any).self
        ]
    }
}
