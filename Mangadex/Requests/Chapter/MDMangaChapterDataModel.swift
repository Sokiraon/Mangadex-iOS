//
//  MDMangaChapterDataModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import YYModel

// MARK: - Chapter Info

class MDMangaChapterAttrs: NSObject {
    var pages: Int = 0
    @objc var volume: String?
    /// No. of chapter
    @objc var chapter: String?
    /// Name of chapter
    @objc var title: String?
    /// If not nil, leads to an external site that views the manga
    @objc var externalUrl: String?
    @objc var createdAt: String!
    @objc var updatedAt: String!
    @objc var publishAt: String!
    @objc var readableAt: String!
    @objc var translatedLanguage: String!
    
    var chapterName: String {
        if !title.isBlank {
            return title!
        } else if !chapter.isBlank {
            return "kMangaChapterNameSimple".localizedFormat(chapter!)
        } else {
            return "kMangaChapterNameNull".localized()
        }
    }
    
    var fullChapterName: String {
        if !chapter.isBlank && !title.isBlank {
            return "kMangaChapterNameDetailed".localizedFormat(chapter!, title!)
        } else if !chapter.isBlank {
            return "kMangaChapterNameSimple".localizedFormat(chapter!)
        } else if !title.isBlank {
            return title!
        } else {
            return "kMangaChapterNameNull".localized()
        }
    }
}

class MDMangaChapterModel: NSObject, YYModel {
    @objc var id: String!
    @objc var attributes: MDMangaChapterAttrs!
    @objc var relationships: [MDRelationshipModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": MDRelationshipModel.self ]
    }
    
    var scanlationGroup: MDScanlationGroupModel? {
        for relationship in relationships {
            if relationship.type == "scanlation_group" {
                return MDScanlationGroupModel(superModel: relationship)
            }
        }
        return nil
    }
    
    var mangaId: String? {
        for relationship in relationships {
            if relationship.type == "manga" {
                return relationship.id
            }
        }
        return nil
    }
}

// MARK: - Chapter Pages Data

class MDMangaChapterPages: NSObject, YYModel {
    @objc var chapterHash: String!
    @objc var data: [String]!
    @objc var dataSaver: [String]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["data": String.self, "dataSaver": String.self]
    }
    
    static func modelCustomPropertyMapper() -> [String : Any]? {
        ["chapterHash": "hash"]
    }
}

class MDMangaChapterPagesModel: NSObject {
    @objc var baseUrl: String!
    @objc var chapter: MDMangaChapterPages!
}
