//
//  MDMangaAggregatedModel.swift
//  Mangadex
//
//  Created by John Rion on 12/22/22.
//

import Foundation
import YYModel

class MDMangaAggregatedVolumeChapter: NSObject {
    @objc var chapter: String!
    @objc var id: String!
}

class MDMangaAggregatedVolume: NSObject, YYModel {
    var count: Int!
    @objc var volume: String!
    @objc var chapters: [String: MDMangaAggregatedVolumeChapter]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "chapters": MDMangaAggregatedVolumeChapter.self ]
    }
}

class MDMangaAggregatedModel: NSObject, YYModel {
    @objc var volumes: [String: MDMangaAggregatedVolume]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "volumes": MDMangaAggregatedVolume.self ]
    }
    
    var chapters: [MDMangaAggregatedChapter] {
        let mapped = volumes.compactMap { _, volumeModel in
            volumeModel.chapters.compactMap { _, chapterModel in
                MDMangaAggregatedChapter(
                    id: chapterModel.id, volume: volumeModel.volume, chapter: chapterModel.chapter
                )
            }
        }
        return Array(mapped.joined()).sorted { chapter1, chapter2 in
            chapter1.chapter.localizedStandardCompare(chapter2.chapter) == .orderedAscending
        }
    }
}

class MDMangaAggregatedChapter {
    let id: String
    let volume: String
    let chapter: String
    
    init(id: String, volume: String, chapter: String) {
        self.id = id
        self.volume = volume
        self.chapter = chapter
    }
}
