//
//  MDMangaItemDataModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import YYModel

class MDMangaMultiLanguageObject: NSObject, YYModel {
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

class MDMangaItemAttributes: NSObject, YYModel {
    @objc var title: [String: Any]!
    @objc var altTitles: [[String: Any]]!
    @objc var descript: [String: Any]?
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
    
    func getLocalizedTitle() -> String {
        let locale = MDLocale.current
        let altLocale = MDLocale.altLocale
        var altTitle: String?
        if let titleValue = title[locale] as? String {
            return titleValue
        } else if let titleValue = title[altLocale] as? String {
            altTitle = titleValue
        }
        for altTitleObj in altTitles {
            if let titleValue = altTitleObj[locale] as? String {
                return titleValue
            } else if let titleValue = altTitleObj[altLocale] as? String {
                altTitle = titleValue
            }
        }
        if altTitle == nil {
            altTitle = Array(title.values)[0] as? String
        }
        return altTitle ?? "N/A"
    }
    
    var localizedDescription: String {
        let locale = MDLocale.current
        let altLocale = MDLocale.altLocale
        if let str = descript?[locale] as? String {
            return str
        } else if let str = descript?[altLocale] as? String {
            return str
        }
        return Array(title.values)[0] as? String ?? "kMangaNoDescr".localized()
    }
}

class MDMangaItemDataModel: NSObject, YYModel {
    @objc var id: String!
    @objc var attributes: MDMangaItemAttributes!
    @objc var relationships: [MDMangaRelationshipItem]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["relationships": MDMangaRelationshipItem.classForCoder()]
    }
}
