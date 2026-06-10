//
//  AuthorModel.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation

struct AuthorAttributes: Codable {
    var name: String
    var imageUrl: String?
    var createdAt: String
    var updatedAt: String
    var twitter: String?
    var pixiv: String?
    var melonBook: String?
    var fanBox: String?
    var booth: String?
    var nicoVideo: String?
    var skeb: String?
    var fantia: String?
    var tumblr: String?
    var youtube: String?
    var weibo: String?
    var naver: String?
    var website: String?
}

struct AuthorRelationship: Codable {
    var id: String
    var type: String
}

protocol AuthorRepresentable {
    var id: String { get }
    var type: String { get }
    var attributes: AuthorAttributes { get }
}

struct AuthorReference: Codable, AuthorRepresentable {
    let id: String
    let type: String
    let attributes: AuthorAttributes
}

struct AuthorModel: Codable, AuthorRepresentable {
    let id: String
    let type: String
    let attributes: AuthorAttributes
    let relationships: [AuthorRelationship]
}

struct AuthorCollection: Codable {
    var limit = 0
    var offset = 0
    var total = 0
    var data: [AuthorModel]
}
