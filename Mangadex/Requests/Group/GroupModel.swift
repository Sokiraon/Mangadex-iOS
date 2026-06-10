//
//  GroupModel.swift
//  Mangadex
//
//  Created by John Rion on 12/21/22.
//

import Foundation

struct GroupAttributes: Codable {
    let name: String
    let website: String?
    let discord: String?
    let contactEmail: String?
    let description: String?
    let twitter: String?
    let focusedLanguages: [String]?
    let createdAt: String
    let updatedAt: String
    var locked: Bool = false
    var official: Bool = false
    var inactive: Bool = false
}

protocol GroupRepresentable: Codable {
    var id: String { get }
    var type: String { get }
    var attributes: GroupAttributes { get }
}

struct GroupReference: GroupRepresentable {
    let id: String
    let type: String
    let attributes: GroupAttributes
}

struct GroupModel: GroupRepresentable {
    let id: String
    let type: String
    let attributes: GroupAttributes
    var relationships = [UserModelEssential]()
    
    var leader: UserModelEssential? {
        relationships.first {
            $0.type == "leader"
        }
    }
}

struct GroupCollection: Codable {
    var limit = 0
    var offset = 0
    var total = 0
    var data = [GroupModel]()
}
