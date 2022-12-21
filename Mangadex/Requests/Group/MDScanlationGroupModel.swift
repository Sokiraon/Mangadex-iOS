//
//  MDScanlationGroupModel.swift
//  Mangadex
//
//  Created by John Rion on 12/21/22.
//

import Foundation
import YYModel

class MDScanlationGroupModel: NSObject {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: MDScanlationGroupAttrs!
    
    convenience init(superModel: MDRelationshipModel) {
        self.init()
        id = superModel.id
        type = superModel.type
        attributes = MDScanlationGroupAttrs.yy_model(with: superModel.attributes)
    }
}

class MDScanlationGroupAttrs: NSObject, YYModel {
    @objc var name: String!
    @objc var website: String?
    @objc var discord: String?
    @objc var contactEmail: String?
    @objc var descr: String?
    @objc var twitter: String?
    @objc var focusedLanguage: [String]?
    @objc var createdAt: String!
    @objc var updatedAt: String!
    var locked: Bool!
    var official: Bool!
    var inactive: Bool!
    
    static func modelCustomPropertyMapper() -> [String : Any]? {
        [ "descr": "description" ]
    }
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "focusedLanguage": String.self ]
    }
}
