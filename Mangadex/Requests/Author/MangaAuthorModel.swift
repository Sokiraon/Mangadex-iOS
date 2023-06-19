//
//  MangaAuthorModel.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import YYModel

class MangaAuthorAttributes: NSObject, YYModel {
    @objc var name: String!
    @objc var imageUrl: String?
    @objc var createdAt: String!
    @objc var updatedAt: String!
    @objc var twitter: String?
    @objc var pixiv: String?
    @objc var melonBook: String?
    @objc var fanBox: String?
    @objc var booth: String?
    @objc var nicoVideo: String?
    @objc var skeb: String?
    @objc var fantia: String?
    @objc var tumblr: String?
    @objc var youtube: String?
    @objc var weibo: String?
    @objc var naver: String?
    @objc var website: String?
}

class MangaAuthorRelationship: NSObject {
    @objc var id: String!
    @objc var type: String!
}

class MangaAuthorModel: NSObject, YYModel {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: MangaAuthorAttributes!
    @objc var relationships: [MangaAuthorRelationship] = []
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": MangaAuthorRelationship.self ]
    }
}

class MangaAuthorCollection: NSObject, YYModel {
    @objc var limit = 0
    @objc var offset = 0
    @objc var total = 0
    @objc var data: [MangaAuthorModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "data": MangaAuthorModel.self ]
    }
}
