//
//  CoverArtModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/21.
//

import Foundation
import YYModel

class CoverArtAttributes: NSObject {
    @objc var fileName: String!
    @objc var createdAt: String!
    @objc var updatedAt: String!
    @objc var volume: String?
    @objc var locale: String!
}

class CoverArtModelEssential: NSObject {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: CoverArtAttributes!
}

class CoverArtModel: CoverArtModelEssential, YYModel {
    @objc var relationships = [RelationshipModel]()
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": RelationshipModel.self ]
    }
}

class CoverArtCollection: NSObject, YYModel {
    @objc var data = [CoverArtModel]()
    @objc var limit = 0
    @objc var offset = 0
    @objc var total = 0
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "data": CoverArtModel.self ]
    }
}
