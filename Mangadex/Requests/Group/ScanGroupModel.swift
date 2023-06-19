//
//  ScanGroupModel.swift
//  Mangadex
//
//  Created by John Rion on 12/21/22.
//

import Foundation
import YYModel

class ScanGroupCollection: NSObject, YYModel {
    @objc var limit = 0
    @objc var offset = 0
    @objc var total = 0
    @objc var data: [ScanGroupModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "data": ScanGroupModel.self ]
    }
}

class ScanGroupModel: NSObject, YYModel {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: ScanGroupAttributes!
    @objc var relationships: [ScanGroupRelationship] = []
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": ScanGroupRelationship.self ]
    }
    
    var leader: ScanGroupRelationship? {
        relationships.first { model in
            model.type == "leader"
        }
    }
}

class ScanGroupRelationship: NSObject {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: ScanGroupRelationshipAttrs?
}

class ScanGroupRelationshipAttrs: NSObject, YYModel {
    @objc var roles: [String]!
    @objc var username: String!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "roles": String.self ]
    }
}

class ScanGroupAttributes: NSObject, YYModel {
    @objc var name: String!
    @objc var website: String?
    @objc var discord: String?
    @objc var contactEmail: String?
    @objc var descr: String?
    @objc var twitter: String?
    @objc var focusedLanguages: [String]?
    @objc var createdAt: String!
    @objc var updatedAt: String!
    @objc var locked: Bool = false
    @objc var official: Bool = false
    @objc var inactive: Bool = false
    
    static func modelCustomPropertyMapper() -> [String : Any]? {
        [ "descr": "description" ]
    }
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "focusedLanguages": String.self ]
    }
}
