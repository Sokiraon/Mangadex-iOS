//
//  CustomListModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation

struct CustomListAttributes: Codable {
    let name: String
    let visibility: String
    var version = 1
}

struct CustomListRelationship: Codable {
    let id: String
    let type: String
}

struct CustomListModel: Codable {
    let id: String
    let type: String
    let attributes: CustomListAttributes
    var relationships = [CustomListRelationship]()
    
    var mangaIds: [String] {
        relationships.filter { relationship in
            relationship.type == "manga"
        }.map { relationship in
            relationship.id
        }
    }
}
