//
//  DownloadManager.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/10.
//

import Foundation
import Just
import YYModel
import os
import SwiftData

@MainActor
class DownloadManager: NSObject {
    // MARK: - Initialization
    static let shared = DownloadManager()
    
    private var fileManager: FileManager!
    
    private var container: ModelContainer!
    private var context: ModelContext!
    
    private var session: URLSession!
    private var baseDir: URL!
    private var mangaDir: URL!
    
    private override init() {
        super.init()
        
        let schema = Schema([ChapterDownloadData.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        container = try! ModelContainer(for: schema, configurations: [config])
        
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: "com.sokiraon.Mangadex.mangadownload")
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: .main)
        
        fileManager = FileManager.default
        let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        baseDir = documentDir.appending(path: "downloads")
        mangaDir = baseDir.appending(path: "manga")
        if !fileManager.fileExists(atPath: mangaDir.path()) {
            try? fileManager.createDirectory(at: mangaDir, withIntermediateDirectories: true)
        }
        context = container.mainContext
        restoreDownloads()
    }
    
    // MARK: - Storage related
    func findManga(by mangaID: String) -> MangaModel? {
        let mangaModelPath = mangaDir.appending(components: mangaID, "info.json").path()
        guard
            fileManager.fileExists(atPath: mangaModelPath),
            let data = fileManager.contents(atPath: mangaModelPath),
            let model = MangaModel.yy_model(withJSON: data)
        else { return nil }
        return model
    }
    
    func findChapter(for mangaID: String, by chapterID: String) -> ChapterModel? {
        let chapterModelPath = mangaDir.appending(components: mangaID, chapterID, "info.json").path()
        guard
            fileManager.fileExists(atPath: chapterModelPath),
            let data = fileManager.contents(atPath: chapterModelPath),
            let model = ChapterModel.yy_model(withJSON: data)
        else { return nil }
        return model
    }
    
    func hasDownloaded(chapterID: String, for mangaID: String) -> Bool {
        let chapterPath = mangaDir.appending(components: mangaID, chapterID).path()
        return fileManager.fileExists(atPath: chapterPath)
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
            let coverURL = fileURL.appending(path: "cover.jpg")
            let infoURL = fileURL.appending(path: "info.json")
            guard let infoData = FileManager.default.contents(atPath: infoURL.path),
                  let infoModel = MangaModel.yy_model(withJSON: infoData)
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
            guard !chapterURLs.isEmpty else { continue }
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
    
    func deleteAllChapters() {
        let enumerator = FileManager.default.enumerator(
            at: mangaDir, includingPropertiesForKeys: nil
        )
        for case let fileURL as URL in enumerator! {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    var sizeUsed: UInt64? {
        return try? FileManager.default.allocatedSizeOfDirectory(at: baseDir)
    }
    
    // MARK: - SwiftData
    private func saveDownload(_ chapterDownload: ChapterDownload) {
        let persistentData = chapterDownload.toPersistentData()
        context.insert(persistentData)
        saveContext()
    }
    
    private func restoreDownloads() {
        let fetchDescriptor = FetchDescriptor<ChapterDownloadData>()
        guard let savedDownloads = try? context.fetch(fetchDescriptor) else { return }
        
        for data in savedDownloads {
            if let mangaModel = findManga(by: data.mangaID),
               let chapterModel = findChapter(for: data.mangaID, by: data.chapterID) {
                let download = ChapterDownload.fromPersistentData(data, mangaModel: mangaModel, chapterModel: chapterModel, session: session)
                activeDownloads[data.chapterID] = download
            }
        }
    }
    
    private func deleteFromStorage(chapterID: String) {
        if let downloadData = fetchDownloadData(chapterID: chapterID) {
            context.delete(downloadData)
        }
        saveContext()
    }
    
    private func fetchDownloadData(chapterID: String) -> ChapterDownloadData? {
        let descriptor = FetchDescriptor<ChapterDownloadData>(predicate: #Predicate { $0.chapterID == chapterID })
        return try? context.fetch(descriptor).first
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Download methods
    private var activeDownloads: [String: ChapterDownload] = [:]
    
    func getActiveDownloads() -> [ChapterDownload] {
        return Array(activeDownloads.values)
    }
    
    func hasActiveDownload(for chapterID: String) -> Bool {
        return activeDownloads.values.contains { $0.id == chapterID }
    }
    
    func downloadManga(mangaModel: MangaModel, chapterModels: [ChapterModel]) {
        for chapterModel in chapterModels {
            Task {
                await downloadChapter(mangaModel: mangaModel, chapterModel: chapterModel)
            }
        }
    }
    
    func downloadChapter(
        mangaModel: MangaModel,
        chapterModel: ChapterModel,
        pageURLs: [URL] = [],
        progressHandler: ((Double) -> Void)? = nil
    ) async {
        let chapterDownload = ChapterDownload(mangaModel: mangaModel, chapterModel: chapterModel, pageURLs: pageURLs, progressHandler: progressHandler)
        
        await MainActor.run {
            activeDownloads[chapterDownload.id] = chapterDownload
            saveDownload(chapterDownload)
            // Notify UI to update
            NotificationCenter.default.post(name: .downloadStatusChanged, object: nil)
        }
        
        await prepareChapterDownload(chapterDownload)
        startChapterDownload(chapterDownload)
    }
    
    private func prepareChapterDownload(_ chapterDownload: ChapterDownload) async {
        chapterDownload.status = .preparing
        let fileManager = FileManager.default
        let mangaModel = chapterDownload.mangaModel
        let chapterModel = chapterDownload.chapterModel
        
        let mangaFolder = mangaDir.appending(path: mangaModel.id)
        let chapterFolder = mangaFolder.appending(path: chapterModel.id)
        let pagesFolder = chapterFolder.appending(
            path: SettingsManager.isDataSavingMode ? "data-saver" : "data")
        try? fileManager.createDirectory(at: pagesFolder, withIntermediateDirectories: true)
        
        // Serialize and store manga info
        if let mangaData = mangaModel.yy_modelToJSONData() {
            let mangaInfoURL = mangaFolder.appending(path: "info.json")
            try? mangaData.write(to: mangaInfoURL)
        }
        // Serialize and store chapter info
        if let chapterData = chapterModel.yy_modelToJSONData() {
            let chapterInfoURL = chapterFolder.appending(path: "info.json")
            try? chapterData.write(to: chapterInfoURL)
        }
        
        // Download manga cover
        if let coverURL = mangaModel.coverURL {
            let dest = mangaFolder.appending(path: "cover.jpg")
            if !fileManager.fileExists(atPath: dest.path()) {
                do {
                    let (source, _) = try await URLSession.shared.download(from: coverURL)
                    try fileManager.moveItem(at: source, to: dest)
                } catch {
                    print("Error fetching cover:", error)
                }
            }
        }
        
        await chapterDownload.fetchPageUrlsIfNeeded()
    }
    
    private func startChapterDownload(_ chapterDownload: ChapterDownload) {
        chapterDownload.status = .running
        for url in chapterDownload.pageURLs {
            chapterDownload.retryCount[url] = 0
            startDownload(for: url, in: chapterDownload)
        }
        saveDownload(chapterDownload)
    }
    
    private func startDownload(for url: URL, in chapterDownload: ChapterDownload) {
        let task = session.downloadTask(with: url)
        chapterDownload.tasks.append(task)
        task.resume()
    }
    
    func pauseChapterDownload(chapterID: String) {
        guard let chapterDownload = activeDownloads[chapterID] else { return }
        for (index, task) in chapterDownload.tasks.enumerated() {
            task.cancel { resumeData in
                if let resumeData {
                    chapterDownload.tasks[index] = self.session.downloadTask(withResumeData: resumeData)
                }
            }
        }
        chapterDownload.status = .paused
        saveDownload(chapterDownload)
    }
    
    func resumeChapterDownload(chapterID: String) {
        guard let chapterDownload = activeDownloads[chapterID] else { return }
        for task in chapterDownload.tasks {
            task.resume()
        }
        chapterDownload.status = .running
        saveDownload(chapterDownload)
    }
    
    func retryChapterDownload(chapterID: String) {
        guard let chapterDownload = activeDownloads[chapterID] else { return }
        chapterDownload.retryCount = [:]
        chapterDownload.tasks.forEach { $0.cancel() }
        chapterDownload.tasks = []
        startChapterDownload(chapterDownload)
    }
    
    func cancelChapterDownload(chapterID: String) {
        activeDownloads[chapterID]?.cancel(mangaDir: mangaDir)
        activeDownloads.removeValue(forKey: chapterID)
        deleteFromStorage(chapterID: chapterID)
        // Notify UI to update
        NotificationCenter.default.post(name: .downloadStatusChanged, object: nil)
    }
    
    private func retryDownload(for url: URL, in chapterDownload: ChapterDownload) async {
        guard let retryCount = chapterDownload.retryCount[url], retryCount < chapterDownload.maxRetries else {
            markFailedChapterDownload(chapterDownload)
            return
        }
        chapterDownload.retryCount[url] = retryCount + 1
        print("Retrying download for \(url) (Attempt \(retryCount + 1)/\(chapterDownload.maxRetries))")
        let base: Double = 0.5
        let delay = min(5.0, base * pow(2.0, Double(retryCount)))
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        startDownload(for: url, in: chapterDownload)
    }
    
    private func markFailedChapterDownload(_ chapterDownload: ChapterDownload) {
        chapterDownload.tasks.forEach { $0.cancel() }
        chapterDownload.tasks = []
        chapterDownload.status = .failed
        saveDownload(chapterDownload)
    }
    
    private func finishChapterDownload(_ chapterDownload: ChapterDownload) {
        activeDownloads.removeValue(forKey: chapterDownload.id)
        deleteFromStorage(chapterID: chapterDownload.id)
        chapterDownload.status = .succeeded
        NotificationCenter.default.post(name: .downloadStatusChanged, object: nil)
    }
    
    private func saveDownloadedFile(from location: URL, to destination: URL) {
        do {
            if FileManager.default.fileExists(atPath: destination.path()) {
                try? FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: location, to: destination)
            print("Saved to: \(destination.path())")
        } catch {
            print("Error saving file:", error)
        }
    }
}


// MARK: - URLSessionDownloadDelegate
extension DownloadManager: @preconcurrency URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard
            let chapterDownload = activeDownloads.first(where: { $0.value.tasks.contains(downloadTask) })?.value,
            let url = downloadTask.originalRequest?.url,
            let pageIndex = chapterDownload.pageURLs.firstIndex(of: url),
            let taskIndex = chapterDownload.tasks.firstIndex(of: downloadTask)
        else { return }
        let pagesFolder = mangaDir.appending(
            components: chapterDownload.mangaModel.id, chapterDownload.id, chapterDownload.pageQuality)
        let destination = pagesFolder.appending(path: "\(pageIndex+1).\(url.pathExtension)")
        saveDownloadedFile(from: location, to: destination)
        
        chapterDownload.completedPages += 1
        let progress = Double(chapterDownload.completedPages) / Double(chapterDownload.totalPages)
        chapterDownload.progress = progress
        chapterDownload.progressHandler?(progress)
        
        chapterDownload.tasks.remove(at: taskIndex)
        saveDownload(chapterDownload)
        if chapterDownload.completedPages == chapterDownload.totalPages {
            finishChapterDownload(chapterDownload)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard
            let url = task.originalRequest?.url,
            let downloadTask = task as? URLSessionDownloadTask,
            let chapterDownload = activeDownloads.first(where: { $0.value.tasks.contains(downloadTask) })?.value
        else {
            return
        }
        
        if let error = error as? URLError, error.code == .cancelled {
            return
        }
        
        if let error {
            print("Download failed for \(url): \(error.localizedDescription)")
            Task { await self.retryDownload(for: url, in: chapterDownload) }
        }
    }
}
