//
//  MangaFeedModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/28.
//

import Foundation
import YYModel

class MangaFeedModel: NSObject, YYModel {
    var limit = 0
    var offset = 0
    var total = 0
    @objc var data: [MDMangaChapterModel]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["data": MDMangaChapterModel.self]
    }
    
    lazy var aggregated: [String: [MDMangaChapterModel]] = {
        var result: [String: [MDMangaChapterModel]] = [:]
        for chapterModel in data {
            let mangaId = chapterModel.mangaId!
            if result.contains(mangaId) {
                result[mangaId]?.append(chapterModel)
            } else {
                result[mangaId] = [chapterModel]
            }
        }
        return result
    }()
}
