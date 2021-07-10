//
//  MDMangaItemDataModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import YYModel

class MDMangaMultiLanguageObject: NSObject {
    @objc var en: String!
}

class MDMangaItemAttributes: NSObject, YYModel {
    @objc var title: MDMangaMultiLanguageObject!
    @objc var descript: MDMangaMultiLanguageObject!
    @objc var status: String!
    @objc var tags: [MDMangaTagDataModel]!
    @objc var lastVolume: String?
    @objc var lastChapter: String?

    class func modelCustomPropertyMapper() -> [String: Any]? {
        ["descript": "description"]
    }

    class func modelContainerPropertyGenericClass() -> [String: Any]? {
        ["tags": MDMangaTagDataModel.classForCoder()]
    }
}

class MDMangaItemRelationship: NSObject {
    @objc var id: String!
    @objc var type: String!
}

class MDMangaItemData: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaItemAttributes!
}

class MDMangaItemDataModel: NSObject, YYModel {
    @objc var data: MDMangaItemData!
    @objc var relationships: [MDMangaItemRelationship]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["relationships": MDMangaItemRelationship.classForCoder()]
    }
}
