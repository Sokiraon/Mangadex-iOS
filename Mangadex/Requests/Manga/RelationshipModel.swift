//
//  RelationshipModel.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import YYModel

class RelationshipModel: NSObject, YYModel {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: [String: Any]?
    @objc var related: String?
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [
            "attributes": (Any).self
        ]
    }
}

extension Array where Element: RelationshipModel {
    var authors: [AuthorModelEssential] {
        filter { relationship in
            relationship.type == "author" &&
            relationship.attributes != nil
        }.map { relationship in
            let model = AuthorModelEssential()
            model.id = relationship.id
            model.type = relationship.type
            model.attributes = AuthorAttributes.yy_model(
                withJSON: relationship.attributes!)
            return model
        }
    }
    
    var artists: [AuthorModelEssential] {
        filter { relationship in
            relationship.type == "artist" &&
            relationship.attributes != nil
        }.map { relationship in
            let model = AuthorModelEssential()
            model.id = relationship.id
            model.type = relationship.type
            model.attributes = AuthorAttributes.yy_model(
                withJSON: relationship.attributes!)
            return model
        }
    }
    
    var coverArt: CoverArtModelEssential? {
        first { relationship in
            relationship.type == "cover_art" &&
            relationship.attributes != nil
        }.map { relationship in
            let model = CoverArtModelEssential()
            model.id = relationship.id
            model.type = relationship.type
            model.attributes = CoverArtAttributes.yy_model(
                withJSON: relationship.attributes!)
            return model
        }
    }
    
    var group: GroupModelEssential? {
        if let model = first(where: { relationship in
            relationship.type == "scanlation_group" &&
            relationship.attributes != nil
        }) {
            let result = GroupModelEssential()
            result.id = model.id
            result.type = model.type
            result.attributes = GroupAttributes.yy_model(
                withJSON: model.attributes!)
            return result
        }
        return nil
    }
    
    var user: UserModelEssential? {
        if let model = first(where: { relationship in
            relationship.type == "user"
        }) {
            let user = UserModelEssential()
            user.id = model.id
            user.type = model.type
            user.attributes = UserAttributes.yy_model(
                withJSON: model.attributes!)
            return user
        }
        return nil
    }
    
    var mangaModel: MangaModelEssential? {
        if let relationship = first(where: { relationship in
            relationship.type == "manga" &&
            relationship.attributes != nil
        }) {
            let model = MangaModelEssential()
            model.id = relationship.id
            model.attributes = MangaAttributes.yy_model(
                withJSON: relationship.attributes!)
            return model
        }
        return nil
    }
    
    /// - Returns: Dictionary, where key is relatedType, element is array of mangaIDs.
    var relatedManga: [String: [String]] {
        var res = [String: [String]]()
        filter { $0.related != nil }
            .forEach { model in
                if res.contains(model.related!) {
                    res[model.related!]?.append(model.id)
                } else {
                    res[model.related!] = [model.id]
                }
            }
        return res
    }
}
