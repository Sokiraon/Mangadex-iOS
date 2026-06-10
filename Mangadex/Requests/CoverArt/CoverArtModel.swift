//
//  CoverArtModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/21.
//

import Foundation

struct CoverArtAttributes: Codable {
    let fileName: String
    let createdAt: String
    let updatedAt: String
    let volume: String?
    let locale: String
}

protocol CoverArtRepresentable: Codable {
    var id: String { get }
    var type: String { get }
    var attributes: CoverArtAttributes { get }
}

struct CoverArtReference: CoverArtRepresentable {
    let id: String
    let type: String
    let attributes: CoverArtAttributes
}

struct CoverArtModel: CoverArtRepresentable {
    let id: String
    let type: String
    let attributes: CoverArtAttributes
    var relationships = [RelationshipModel]()
    
    func getHDUrl(mangaId: String) -> URL? {
        URL(string: "\(HostUrl.uploads.rawValue)/covers/\(mangaId)/\(attributes.fileName).512.jpg")
    }
    
    func getOriginalUrl(mangaId: String) -> URL? {
        URL(string: "\(HostUrl.uploads.rawValue)/covers/\(mangaId)/\(attributes.fileName)")
    }
}

struct CoverArtCollection: Codable {
    var data = [CoverArtModel]()
    var limit = 0
    var offset = 0
    var total = 0
}
