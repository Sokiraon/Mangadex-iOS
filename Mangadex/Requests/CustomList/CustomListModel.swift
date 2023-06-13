//
//  CustomListModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation
import YYModel

class CustomListAttributes: NSObject {
    @objc var name: String!
    @objc var visibility: String!
    @objc var version = 1
}

class CustomListRelationship: NSObject {
    @objc var id: String!
    @objc var type: String!
}

class CustomListModel: NSObject, YYModel {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: CustomListAttributes!
    @objc var relationships = [CustomListRelationship]()
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": CustomListRelationship.self ]
    }
    
    var mangaIds: [String] {
        relationships.filter { relationship in
            relationship.type == "manga"
        }.map { relationship in
            relationship.id
        }
    }
}
