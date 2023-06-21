//
//  ChapterModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import YYModel
import FlagKit

// MARK: - Chapter Info

class ChapterAttributes: NSObject {
    @objc var pages: Int = 0
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
    
    var languageFlag: UIImage? {
        var countryCode = MDLocale.languageToCountryCode[translatedLanguage]
        countryCode = countryCode ?? translatedLanguage.prefix(2).uppercased()
        let flag = Flag(countryCode: countryCode!)
        return flag?.originalImage
    }
}

class ChapterModel: NSObject, YYModel {
    @objc var id: String!
    @objc var attributes: ChapterAttributes!
    @objc var relationships: [RelationshipModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "relationships": RelationshipModel.self ]
    }
    
    var mangaId: String? {
        for relationship in relationships {
            if relationship.type == "manga" {
                return relationship.id
            }
        }
        return nil
    }
    
    var mangaModel: MangaModel?
}

class ChapterCollection: NSObject, YYModel {
    @objc var limit = 0
    @objc var offset = 0
    @objc var total = 0
    @objc var data = [ChapterModel]()
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "data": ChapterModel.self ]
    }
    
    lazy var aggregatedByManga: [String: [ChapterModel]] = {
        var result: [String: [ChapterModel]] = [:]
        for chapterModel in data {
            let mangaId = chapterModel.mangaId!
            if result.contains(mangaId) {
                result[mangaId]?.append(chapterModel)
            } else {
                result[mangaId] = [chapterModel]
            }
        }
        return result
    }()
}
