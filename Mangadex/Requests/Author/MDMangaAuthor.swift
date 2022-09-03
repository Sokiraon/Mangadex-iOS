//
//  AuthorModel.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import YYModel

class MDMangaAuthorAttributes: NSObject, YYModel {
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

class MDMangaAuthor: NSObject, YYModel {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: MDMangaAuthorAttributes!
    
    convenience init(relationshipItem: MDMangaRelationshipItem) {
        self.init()
        id = relationshipItem.id
        type = relationshipItem.type
        attributes = MDMangaAuthorAttributes.yy_model(with: relationshipItem.attributes)
    }
}
