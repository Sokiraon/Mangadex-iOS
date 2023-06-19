//
//  MDRelationshipModel.swift
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

class MDRelationshipModel: NSObject, YYModel {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: [String: Any]?
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [
            "attributes": (Any).self
        ]
    }
}

extension Array where Element: MDRelationshipModel {
    var authors: [MangaAuthorModel] {
        filter { relationship in
            relationship.type == "author" &&
            relationship.attributes != nil
        }.map { relationship in
            let model = MangaAuthorModel()
            model.id = relationship.id
            model.type = relationship.type
            model.attributes = MangaAuthorAttributes.yy_model(
                withJSON: relationship.attributes!)
            return model
        }
    }
    
    var artists: [MangaAuthorModel] {
        filter { relationship in
            relationship.type == "artist" &&
            relationship.attributes != nil
        }.map { relationship in
            let model = MangaAuthorModel()
            model.id = relationship.id
            model.type = relationship.type
            model.attributes = MangaAuthorAttributes.yy_model(
                withJSON: relationship.attributes!)
            return model
        }
    }
    
    var groups: [ScanGroupModel] {
        filter { relationship in
            relationship.type == "scanlation_group" &&
            relationship.attributes != nil
        }.map { relationship in
            let model = ScanGroupModel()
            model.id = relationship.id
            model.type = relationship.type
            model.attributes = ScanGroupAttributes.yy_model(
                withJSON: relationship.attributes!)
            return model
        }
    }
}
