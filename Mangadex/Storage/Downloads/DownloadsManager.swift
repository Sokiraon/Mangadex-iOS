//
//  DownloadsManager.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/10.
//

import Foundation
import Just
import YYModel

fileprivate let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

class DownloadsManager {
    
    static let `default` = DownloadsManager()
    
    lazy var baseDir = documentDir.appendingPathComponent("downloads")
    lazy var mangaDir = baseDir.appendingPathComponent("manga")
    
    private init() {
        if !FileManager.default.fileExists(atPath: mangaDir.path) {
            try? FileManager.default.createDirectory(at: mangaDir, withIntermediateDirectories: true)
        }
    }
    
    func downloadChapter(
        mangaModel: MDMangaItemDataModel,
        chapterModel: MDMangaChapterModel,
        pageURLs: [URL]
    ) async {
        do {
            let dir = mangaDir.appendingPathComponent(mangaModel.id)
            // Serialize and store manga info
            if let mangaData = mangaModel.yy_modelToJSONData() {
                let mangaInfoURL = dir.appendingPathComponent("info.json")
                try mangaData.write(to: mangaInfoURL)
            }
            // Create dir to save chapter pages
            let chapterDir = dir.appendingPathComponent(chapterModel.id)
            try FileManager.default.createDirectory(at: chapterDir, withIntermediateDirectories: true)
            // Serialize and store chapter info
            if let chapterData = chapterModel.yy_modelToJSONData() {
                let chapterInfoURL = chapterDir.appendingPathComponent("info.json")
                try chapterData.write(to: chapterInfoURL)
            }
            // Download manga cover
            if let coverURL = mangaModel.coverURL {
                let destURL = dir.appendingPathComponent("cover.jpg")
                try await downloadFile(from: coverURL, to: destURL)
            }
            // Download chapter pages
            for (index, pageURL) in pageURLs.enumerated() {
                let pathExtension = pageURL.pathExtension
                let destURL = chapterDir.appendingPathComponent("\(index).\(pathExtension)")
                try await downloadFile(from: pageURL, to: destURL)
            }
        } catch {
            // TODO: Handle download error
        }
    }
    
    private func downloadFile(from url: URL, to dest: URL) async throws {
        let (source, _) = try await URLSession.shared.download(from: url)
        try FileManager.default.moveItem(at: source, to: dest)
    }
    
    func retrieveChapters() -> [LocalMangaModel]? {
        guard FileManager.default.fileExists(atPath: mangaDir.path) else {
            return nil
        }
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey]
        let resourceKeysSet = Set(resourceKeys)
        let enumerator = FileManager.default.enumerator(
            at: mangaDir,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsSubdirectoryDescendants]
        )
        var mangaModels: [LocalMangaModel] = []
        for case let fileURL as URL in enumerator! {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeysSet),
                  resourceValues.isDirectory ?? false
            else {
                continue
            }
            let coverURL = fileURL.appendingPathComponent("cover.jpg")
            let infoURL = fileURL.appendingPathComponent("info.json")
            guard let infoData = FileManager.default.contents(atPath: infoURL.path),
                  let infoModel = MDMangaItemDataModel.yy_model(withJSON: infoData)
            else {
                continue
            }
            var chapterURLs: [URL] = []
            let subEnumerator = FileManager.default.enumerator(
                at: fileURL,
                includingPropertiesForKeys: resourceKeys,
                options: [.skipsSubdirectoryDescendants]
            )
            for case let subFileURL as URL in subEnumerator! {
                guard let resourceValues = try? subFileURL.resourceValues(forKeys: resourceKeysSet),
                      resourceValues.isDirectory ?? false
                else {
                    continue
                }
                chapterURLs.append(subFileURL)
            }
            let mangaModel = LocalMangaModel(
                baseURL: fileURL,
                coverURL: coverURL,
                chapterURLs: chapterURLs,
                info: infoModel
            )
            mangaModels.append(mangaModel)
        }
        return mangaModels
    }
}
