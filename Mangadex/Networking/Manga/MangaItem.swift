//
//  MangaItem.swift
//  Mangadex
//
//  Created by John Rion on 12/6/21.
//

import Foundation

struct MangaItem {
    var id: String
    var title: String
    var authorId: String
    var artistId: String
    var coverId: String
    var description: String
    var tags: [String]
    
    init(model: MDMangaItemDataModel) {
        self.id = model.id
        self.title = model.attributes.getLocalizedTitle()
        self.description = model.attributes.descript.localizedString()
        
        self.authorId = ""; self.artistId = ""; self.coverId = ""
        for relationship in model.relationships {
            switch relationship.type {
            case "author":
                self.authorId = relationship.id
                break
            case "artist":
                self.artistId = relationship.id
                break
            case "cover_art":
                self.coverId = relationship.id
                break
            default:
                break
            }
        }
        
        var tags: [String] = []
        for tag in model.attributes.tags {
            tags.append(tag.attributes.localizedName())
        }
        self.tags = tags
    }
}
