//
//  GroupModel.swift
//  Mangadex
//
//  Created by John Rion on 12/21/22.
//

import Foundation
import YYModel

class GroupCollection: NSObject, YYModel {
    @objc var limit = 0
    @objc var offset = 0
    @objc var total = 0
    @objc var data: [GroupModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "data": GroupModel.self ]
    }
}

class GroupModelEssential: NSObject {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: GroupAttributes!
}

class GroupModel: GroupModelEssential, YYModel {
    @objc var relationships: [UserModelEssential] = []
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": UserModelEssential.self ]
    }
    
    var leader: UserModelEssential? {
        relationships.first { model in
            model.type == "leader"
        }
    }
}

class GroupAttributes: NSObject, YYModel {
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
