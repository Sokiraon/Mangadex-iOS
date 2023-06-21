//
//  MangaCollection.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import YYModel

enum MangaReadingStatus: String {
    case reading = "reading"
    case onHold = "on_hold"
    case planToRead = "plan_to_read"
    case dropped = "dropped"
    case reReading = "re_reading"
    case completed = "completed"
    /// Represents the "unfollowed" status.
    case null = "null"
}

class MangaMultiLanguageObject: NSObject, YYModel {
    @objc var en: String?
    @objc var jp: String?
    @objc var zh: String?
    @objc var zhHk: String?
    
    func localizedString() -> String {
        let localized = value(forKey: MDLocale.propertySafeLocale()) as? String
        if localized == nil {
            if en != nil {
                return en!
            }
            for name in propertyNames() {
                if let property = value(forKey: name) as? String {
                    return property
                }
            }
        } else {
            return localized!
        }
        return "N/A"
    }
    
    class func modelCustomPropertyMapper() -> [String: Any]? {
        ["zhHk": "zh-hk"]
    }
}

class MangaAttributes: NSObject, YYModel {
    @objc var title: [String: String]!
    @objc var altTitles: [[String: String]]!
    @objc var descript: [String: String]?
    @objc var status: String!
    @objc var tags: [MDMangaTagDataModel]!
    @objc var lastVolume: String?
    @objc var lastChapter: String?
    @objc var updatedAt: String!

    class func modelCustomPropertyMapper() -> [String: Any]? {
        ["descript": "description"]
    }

    class func modelContainerPropertyGenericClass() -> [String: Any]? {
        [
            "tags": MDMangaTagDataModel.classForCoder(),
            "title": Any.self,
            "altTitles": Any.self,
        ]
    }
    
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
        if let description = descript {
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

class MangaModelEssential: NSObject {
    @objc var id: String!
    @objc var attributes: MangaAttributes!
}

class MangaModel: MangaModelEssential, YYModel {
    @objc var relationships: [RelationshipModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["relationships": RelationshipModel.classForCoder()]
    }
    
    var authors: [AuthorModelEssential] {
        relationships.authors
    }
    
    var primaryAuthor: AuthorModelEssential? {
        authors.first
    }
    
    var primaryAuthorName: String {
        primaryAuthor?.attributes?.name ?? "kAuthorUnknown".localized()
    }
    
    var artists: [AuthorModelEssential] {
        relationships.artists
    }
    
    var coverArts: [CoverArtModelEssential] {
        relationships.coverArts
    }
    
    var coverURL: URL? {
        guard let model = coverArts.first else {
            return nil
        }
        let urlStr = "\(HostUrl.uploads.rawValue)/covers/\(id!)/\(model.attributes.fileName!).256.jpg"
        return URL(string: urlStr)
    }
    
    var coverURLHD: URL? {
        if SettingsManager.isDataSavingMode {
            return coverURL
        }
        guard let model = coverArts.first else {
            return nil
        }
        let urlStr = "\(HostUrl.uploads.rawValue)/covers/\(id!)/\(model.attributes.fileName!).512.jpg"
        return URL(string: urlStr)
    }
    
    var statistics: MangaStatisticsModel?
}

class MangaCollection: NSObject, YYModel {
    @objc var data: [MangaModel]!
    @objc var limit = 0
    @objc var offset = 0
    @objc var total = 0
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "data": MangaModel.self ]
    }
}
