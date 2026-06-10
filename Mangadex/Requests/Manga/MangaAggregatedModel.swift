//
//  MangaAggregatedModel.swift
//  Mangadex
//
//  Created by John Rion on 12/22/22.
//

import Foundation

struct MangaAggregatedVolumeChapter: Codable {
    let id: String
    let chapter: String
}

struct MangaAggregatedVolume: Codable {
    let count: Int?
    let volume: String
    let chapters: [String: MangaAggregatedVolumeChapter]?

    var sortedChapters: [MangaAggregatedVolumeChapter] {
        guard let chapters = chapters?.values else {
            return []
        }
        return chapters.sorted { chapter1, chapter2 in
            chapter1.chapter.localizedStandardCompare(chapter2.chapter) == .orderedDescending
        }
    }
}

struct MangaAggregatedModel: Codable {
    let volumes: [String: MangaAggregatedVolume]

    var volumeNames: [String] {
        let names = Array(volumes.keys)
        return names.sorted { name1, name2 in
            name1.localizedStandardCompare(name2) == .orderedDescending
        }
    }

    func getOrderedChapters() -> [MangaAggregatedChapter] {
        let mapped = volumes.compactMap { _, volumeModel in
            volumeModel.chapters?.compactMap { _, chapterModel in
                MangaAggregatedChapter(
                    id: chapterModel.id,
                    volume: volumeModel.volume,
                    chapter: chapterModel.chapter
                )
            }
        }
        return Array(mapped.joined()).sorted { chapter1, chapter2 in
            chapter1.chapter
                .localizedStandardCompare(chapter2.chapter) == .orderedAscending
        }
    }
}

struct MangaAggregatedChapter: Codable {
    let id: String
    let volume: String
    let chapter: String
}
