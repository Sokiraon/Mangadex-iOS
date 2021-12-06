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
    @objc var title: MDMangaMultiLanguageObject!
    @objc var altTitles: [MDMangaMultiLanguageObject]!
    @objc var descript: MDMangaMultiLanguageObject!
    @objc var status: String!
    @objc var tags: [MDMangaTagDataModel]!
    @objc var lastVolume: String?
    @objc var lastChapter: String?

    class func modelCustomPropertyMapper() -> [String: Any]? {
        ["descript": "description"]
    }

    class func modelContainerPropertyGenericClass() -> [String: Any]? {
        [
            "tags": MDMangaTagDataModel.classForCoder(),
            "altTitles": MDMangaMultiLanguageObject.classForCoder()
        ]
    }
    
    func getLocalizedTitle() -> String {
        let locale = MDLocale.propertySafeLocale()
        let titleValue = title.value(forKey: locale)
        if (titleValue != nil) {
            return titleValue as! String
        }
        for altTitleObj in altTitles {
            let value = altTitleObj.value(forKey: locale)
            if (value != nil) {
                return value as! String
            }
            let str = altTitleObj.en
            if (str != nil && str?.guessedLocale() == locale) {
                return str!
            }
        }
        return title.localizedString()
    }
}

class MDMangaItemRelationship: NSObject {
    @objc var id: String!
    @objc var type: String!
}

class MDMangaItemDataModel: NSObject, YYModel {
    @objc var id: String!
    @objc var attributes: MDMangaItemAttributes!
    @objc var relationships: [MDMangaItemRelationship]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["relationships": MDMangaItemRelationship.classForCoder()]
    }
}
