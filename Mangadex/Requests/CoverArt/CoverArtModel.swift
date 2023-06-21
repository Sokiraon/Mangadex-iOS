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
