//
//  AuthorModel.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import YYModel

class AuthorAttributes: NSObject, YYModel {
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

class AuthorRelationship: NSObject {
    @objc var id: String!
    @objc var type: String!
}

class AuthorModelEssential: NSObject {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: AuthorAttributes!
}

class AuthorModel: AuthorModelEssential, YYModel {
    @objc var relationships: [AuthorRelationship] = []
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": AuthorRelationship.self ]
    }
}

class AuthorCollection: NSObject, YYModel {
    @objc var limit = 0
    @objc var offset = 0
    @objc var total = 0
    @objc var data: [AuthorModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "data": AuthorModel.self ]
    }
}
