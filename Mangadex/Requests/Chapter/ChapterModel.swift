//
//  ChapterModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import FlagKit

// MARK: - Chapter Info

struct ChapterAttributes: Codable {
    var pages: Int = 0
    var volume: String?
    /// No. of chapter
    var chapter: String?
    /// Name of chapter
    var title: String?
    /// If not nil, leads to an external site that views the manga
    var externalUrl: String?
    var createdAt: String
    var updatedAt: String
    var publishAt: String
    var readableAt: String
    var translatedLanguage: String
    
    var chapterName: String {
        if !title.isBlank {
            return title!
        } else if !chapter.isBlank {
            return "kMangaChapterNameSimple".localizedFormat(chapter!)
        } else {
            return "kMangaChapterNameNull".localized()
        }
    }
    
    /// "Ch. X" (en) or "第 X 话" (zh)
    var simpleChapterName: String {
        if !chapter.isBlank {
            return "kMangaChapterNameSimple".localizedFormat(chapter!)
        }
        return "kMangaChapterNameNull".localized()
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

struct ChapterModel: Codable {
    let id: String
    let attributes: ChapterAttributes
    let relationships: [RelationshipModel]
    
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

struct ChapterCollection: Codable {
    var limit = 0
    var offset = 0
    var total = 0
    var data = [ChapterModel]()
    
    var aggregatedByManga: [String: [ChapterModel]] {
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
    }
}
