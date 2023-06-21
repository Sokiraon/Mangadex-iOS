//
//  ChapterPagesModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/21.
//

import Foundation
import YYModel

class ChapterPages: NSObject, YYModel {
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

class ChapterPagesModel: NSObject {
    @objc private var baseUrl: String!
    @objc private var chapter: ChapterPages!
    
    var pageURLs: [URL] {
        if SettingsManager.isDataSavingMode {
            return chapter.dataSaver.map { fileName in
                URL(string: "\(baseUrl!)/data-saver/\(chapter.chapterHash!)/\(fileName)")!
            }
        } else {
            return chapter.data.map { fileName in
                URL(string: "\(baseUrl!)/data/\(chapter.chapterHash!)/\(fileName)")!
            }
        }
    }
}
