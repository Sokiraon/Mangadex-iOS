//
//  MDMangaChapterDataModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import YYModel

class MDMangaChapterAttributes: NSObject, YYModel {
    @objc var volume: String?
    @objc var chapter: String!
    @objc var title: String?
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

class MDMangaChapterData: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaChapterAttributes!
}

class MDMangaChapterDataModel: NSObject {
    @objc var data: MDMangaChapterData!
}
