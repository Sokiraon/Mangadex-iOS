//
//  RelationshipModel.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation

enum RelationshipAttributes: Codable {
    case author(AuthorAttributes)
    case coverArt(CoverArtAttributes)
    case group(GroupAttributes)
    case user(UserAttributes)
    case manga(MangaAttributes)
    case unknown(JSONValue)
}

struct RelationshipModel: Codable {
    let id: String
    let type: String
    let related: String?
    let attributes: RelationshipAttributes?
}

extension RelationshipModel {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case related
        case attributes
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        related = try container.decodeIfPresent(String.self, forKey: .related)

        guard container.contains(.attributes) else {
            attributes = nil
            return
        }
        if try container.decodeNil(forKey: .attributes) {
            attributes = nil
            return
        }

        switch type {
        case "author", "artist":
            attributes =
                .author(
                    try container.decode(AuthorAttributes.self, forKey: .attributes)
                )
        case "cover_art":
            attributes =
                .coverArt(
                    try container.decode(CoverArtAttributes.self, forKey: .attributes)
                )
        case "scanlation_group":
            attributes =
                .group(
                    try container.decode(GroupAttributes.self, forKey: .attributes)
                )
        case "user":
            attributes =
                .user(
                    try container.decode(UserAttributes.self, forKey: .attributes)
                )
        case "manga":
            attributes =
                .manga(
                    try container.decode(MangaAttributes.self, forKey: .attributes)
                )
        default:
            attributes =
                .unknown(
                    try container.decode(JSONValue.self, forKey: .attributes)
                )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(related, forKey: .related)

        switch attributes {
        case .author(let value):
            try container.encode(value, forKey: .attributes)
        case .coverArt(let value):
            try container.encode(value, forKey: .attributes)
        case .group(let value):
            try container.encode(value, forKey: .attributes)
        case .user(let value):
            try container.encode(value, forKey: .attributes)
        case .manga(let value):
            try container.encode(value, forKey: .attributes)
        case .unknown(let value):
            try container.encode(value, forKey: .attributes)
        case nil:
            break
        }
    }
}

extension Array where Element == RelationshipModel {
    var authors: [AuthorReference] {
        compactMap { relationship in
            guard
                relationship.type == "author",
                case .author(let attributes) = relationship.attributes
            else {
                return nil
            }

            return AuthorReference(
                id: relationship.id,
                type: relationship.type,
                attributes: attributes
            )
        }
    }

    var artists: [AuthorReference] {
        compactMap { relationship in
            guard
                relationship.type == "artist",
                case .author(let attributes) = relationship.attributes
            else {
                return nil
            }

            return AuthorReference(
                id: relationship.id,
                type: relationship.type,
                attributes: attributes
            )
        }
    }

    var coverArt: CoverArtReference? {
        for relationship in self where relationship.type == "cover_art" {
            guard case .coverArt(let attributes) = relationship.attributes else {
                continue
            }
            return CoverArtReference(
                id: relationship.id,
                type: relationship.type,
                attributes: attributes
            )
        }
        return nil
    }

    var group: GroupReference? {
        for relationship in self where relationship.type == "scanlation_group" {
            guard case .group(let attributes) = relationship.attributes else {
                continue
            }
            return GroupReference(
                id: relationship.id,
                type: relationship.type,
                attributes: attributes
            )
        }
        return nil
    }

    var user: UserModelEssential? {
        for relationship in self where relationship.type == "user" {
            guard case .user(let attributes) = relationship.attributes else {
                continue
            }
            return UserModelEssential(
                id: relationship.id,
                type: relationship.type,
                attributes: attributes
            )
        }
        return nil
    }

    var mangaModel: MangaReference? {
        for relationship in self where relationship.type == "manga" {
            guard case .manga(let attributes) = relationship.attributes else {
                continue
            }
            return MangaReference(
                id: relationship.id,
                attributes: attributes
            )
        }
        return nil
    }

    /// - Returns: Dictionary, where key is relatedType, element is array of mangaIDs.
    var relatedManga: [String: [String]] {
        var res = [String: [String]]()
        filter { $0.related != nil }
            .forEach { model in
                if res.contains(model.related!) {
                    res[model.related!]?.append(model.id)
                } else {
                    res[model.related!] = [model.id]
                }
            }
        return res
    }
}
