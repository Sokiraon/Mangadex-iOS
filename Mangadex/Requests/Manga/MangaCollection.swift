//
//  MangaCollection.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation

enum MangaReadingStatus: String, Codable, Sendable {
    case reading = "reading"
    case onHold = "on_hold"
    case planToRead = "plan_to_read"
    case dropped = "dropped"
    case reReading = "re_reading"
    case completed = "completed"
}

struct MangaMultiLangObj: Codable {
    let en: String?
    let jp: String?
    let zh: String?
    let zhHk: String?

    enum CodingKeys: String, CodingKey {
        case en
        case jp
        case zh
        case zhHk = "zh-hk"
    }

    func localizedString() -> String {
        let mirror = Mirror(reflecting: self)
        var alternative: String? = nil
        for child in mirror.children {
            if
                child.label == MDLocale.propertySafeLocale(),
                let localized = child.value as? String
            {
                return localized
            }
            else if let localized = child.value as? String {
                alternative = localized
                break
            }
        }
        return en ?? alternative ?? "N/A"
    }
}

struct MangaAttributes: Codable {
    let title: [String: String]
    let altTitles: [[String: String]]
    let description: [String: String]?
    let status: String
    let tags: [MangaTagModel]
    let lastVolume: String?
    let lastChapter: String?
    let updatedAt: String

    var localizedTitle: String {
        let locale = MDLocale.current
        let altLocale = MDLocale.alternative
        var altTitle: String?
        if let titleValue = title[locale] {
            return titleValue
        } else if let titleValue = title[altLocale] {
            altTitle = titleValue
        }
        for altTitleObj in altTitles {
            if let titleValue = altTitleObj[locale] {
                return titleValue
            } else if let titleValue = altTitleObj[altLocale] {
                altTitle = titleValue
            }
        }
        if altTitle == nil {
            altTitle = Array(title.values)[0]
        }
        return altTitle ?? "N/A"
    }

    var localizedDescription: String {
        if let description {
            let locale = MDLocale.current
            let altLocale = MDLocale.alternative
            let fallback = MDLocale.fallback
            if description.contains(locale) {
                return description[locale]!
            }
            if description.contains(altLocale) {
                return description[altLocale]!
            }
            if description.contains(fallback) {
                return description[fallback]!
            }
            if description.count > 0 {
                return description[Array(description.keys)[0]]!
            }
        }
        return "kMangaDetailNoDescr".localized()
    }
}

protocol MangaRepresentable: Codable {
    var id: String { get }
    var attributes: MangaAttributes { get }
}

struct MangaReference: MangaRepresentable {
    let id: String
    let attributes: MangaAttributes
}

struct MangaModel: MangaRepresentable {
    let id: String
    let attributes: MangaAttributes
    let relationships: [RelationshipModel]

    var authors: [AuthorReference] {
        relationships.authors
    }

    var primaryAuthor: AuthorReference? {
        authors.first
    }

    var primaryAuthorName: String {
        primaryAuthor?.attributes.name ?? "kAuthorUnknown".localized()
    }

    var artists: [AuthorReference] {
        relationships.artists
    }

    var coverURL: URL? {
        guard let model = relationships.coverArt else {
            return nil
        }
        let urlStr = "\(HostUrl.uploads.rawValue)/covers/\(id)/\(model.attributes.fileName).256.jpg"
        return URL(string: urlStr)
    }

    var coverURLHD: URL? {
        if SettingsManager.isDataSavingMode {
            return coverURL
        }
        guard let model = relationships.coverArt else {
            return nil
        }
        let urlStr = "\(HostUrl.uploads.rawValue)/covers/\(id)/\(model.attributes.fileName).512.jpg"
        return URL(string: urlStr)
    }

    var coverURLOriginal: URL? {
        if SettingsManager.isDataSavingMode {
            return coverURL
        }
        guard let model = relationships.coverArt else {
            return nil
        }
        let urlStr = "\(HostUrl.uploads.rawValue)/covers/\(id)/\(model.attributes.fileName)"
        return URL(string: urlStr)
    }

    var statistics: MangaStatisticsModel?
}

struct MangaCollection: Codable {
    var data: [MangaModel]
    var limit = 0
    var offset = 0
    var total = 0
}
