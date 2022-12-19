//
//  MDMangaChapterDataModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import YYModel

// MARK: Chapter Info

class MDMangaChapterInfoAttrs: NSObject {
    @objc var volume: String?
    @objc var chapter: String?
    @objc var title: String?
    var pages: Int = 0
}

class MDMangaChapterInfoModel: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaChapterInfoAttrs!
}

// MARK: Chapter Pages Data

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
