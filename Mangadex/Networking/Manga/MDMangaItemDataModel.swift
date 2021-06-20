//
//  MDMangaItemDataModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import YYModel

class MDMangaLanguageString: NSObject {
    @objc var en: String!
}

class MDMangaItemAttributes: NSObject {
    @objc var title: MDMangaLanguageString!
    @objc var descript: MDMangaLanguageString!
    @objc var lastVolume: String?
    @objc var lastChapter: String?
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
        return ["relationships": MDMangaItemRelationship.classForCoder()]
    }
}
