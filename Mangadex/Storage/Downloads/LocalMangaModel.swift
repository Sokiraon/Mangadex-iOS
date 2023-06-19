//
//  LocalMangaModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/11.
//

import Foundation

class LocalChapterModel: Equatable {
    let info: ChapterModel
    var pageURLs: [URL] = []
    
    init(baseURL: URL) {
        let infoURL = baseURL.appendingPathComponent("info.json")
        let infoData = FileManager.default.contents(atPath: infoURL.path)
        self.info = ChapterModel.yy_model(withJSON: infoData!)!
        
        let pagesDir = baseURL.appendingPathComponent("data")
        let pagesDirAlt = baseURL.appendingPathComponent("data-saver")
        
        if FileManager.default.fileExists(atPath: pagesDir.path) {
            let enumerator = FileManager.default.enumerator(
                at: pagesDir,
                includingPropertiesForKeys: nil
            )
            for case let fileURL as URL in enumerator! {
                if fileURL.pathExtension == "png" {
                    pageURLs.append(fileURL)
                }
            }
        } else if FileManager.default.fileExists(atPath: pagesDirAlt.path) {
            let enumerator = FileManager.default.enumerator(
                at: pagesDirAlt,
                includingPropertiesForKeys: nil
            )
            for case let fileURL as URL in enumerator! {
                if fileURL.pathExtension == "jpg" {
                    pageURLs.append(fileURL)
                }
            }
        }
        
        pageURLs.sort { url1, url2 in
            url1.lastPathComponent.localizedStandardCompare(url2.lastPathComponent) == .orderedAscending
        }
    }
    
    static func == (lhs: LocalChapterModel, rhs: LocalChapterModel) -> Bool {
        lhs.info.id == rhs.info.id
    }
}

class LocalMangaModel {
    let baseURL: URL
    let coverURL: URL
    let chapterURLs: [URL]
    let info: MangaModel
    
    init(baseURL: URL, coverURL: URL, chapterURLs: [URL], info: MangaModel) {
        self.baseURL = baseURL
        self.coverURL = coverURL
        self.chapterURLs = chapterURLs
        self.info = info
    }
    
    var chapters: [LocalChapterModel] {
        var models = chapterURLs.map { chapterURL in
            LocalChapterModel(baseURL: chapterURL)
        }
        models.sort { model1, model2 in
            model1.info.attributes.chapter!
                .localizedStandardCompare(model2.info.attributes.chapter!)
            == .orderedAscending
        }
        return models
    }
}
