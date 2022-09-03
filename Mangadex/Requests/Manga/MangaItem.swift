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
    var authors = [MDMangaAuthor]()
    var artists = [MDMangaAuthor]()
    var coverArts = [MDMangaCoverAttributes]()
    var description: String
    
    var formatTags = [String]()
    var genreTags = [String]()
    var themeTags = [String]()
    var contentTags = [String]()
    
    var tags: [[String]] {
        [formatTags, genreTags, themeTags, contentTags]
    }
    
    var updatedAt: String
    var lastVolume: String?
    var lastChapter: String?
    var status: String
    
    init(model: MDMangaItemDataModel) {
        self.id = model.id
        self.title = model.attributes.getLocalizedTitle()
        self.description = model.attributes.descript?.localizedString() ?? "kMangaNoDescr".localized()
        self.status = model.attributes.status
        self.lastVolume = model.attributes.lastVolume
        self.lastChapter = model.attributes.lastChapter
        self.updatedAt = model.attributes.updatedAt
        
        for relationship in model.relationships {
            switch relationship.type {
            case "author":
                self.authors.append(MDMangaAuthor(relationshipItem: relationship))
                break
            case "artist":
                self.artists.append(MDMangaAuthor(relationshipItem: relationship))
                break
            case "cover_art":
                guard let data = MDMangaCoverAttributes.yy_model(with: relationship.attributes) else {
                    break
                }
                self.coverArts.append(data)
                break
            default:
                break
            }
        }
        
        for tag in model.attributes.tags {
            if let tagName = tag.localizedName() {
                switch tag.attributes.group {
                case "format":
                    formatTags.append(tagName)
                    break
                case "genre":
                    genreTags.append(tagName)
                    break
                case "theme":
                    themeTags.append(tagName)
                    break
                case "content":
                    contentTags.append(tagName)
                    break
                default:
                    break
                }
            }
        }
    }
}
