//
//  ChapterDownload.swift
//  Mangadex
//
//  Created by John Rion on 2024/06/21.
//

import Foundation
import PromiseKit

class ChapterDownload {
    enum Status: Int, Codable {
        case waiting = 0
        case preparing
        case running
        case paused
        case failed
        case succeeded
    }
    
    let mangaModel: MangaModel
    let chapterModel: ChapterModel
    var pageURLs: [URL] = []
    var pageQuality: String
    
    var totalPages: Int = 0
    var completedPages: Int = 0
    
    var tasks: [URLSessionDownloadTask] = []
    var retryCount: [URL: Int] = [:]
    let maxRetries = 3
    
    var progress: Double = 0
    var progressHandler: ((Double) -> Void)?
    
    var id: String {
        chapterModel.id
    }

    private var _status: Status
    var status: Status {
        get {
            _status
        }
        set {
            _status = newValue
            notifyStatusChanged()
        }
    }
    
    init(
        mangaModel: MangaModel,
        chapterModel: ChapterModel,
        pageURLs: [URL],
        status: Status = .waiting,
        progressHandler: ((Double) -> Void)? = nil
    ) {
        self.mangaModel = mangaModel
        self.chapterModel = chapterModel
        self.pageURLs = pageURLs
        self.totalPages = pageURLs.count
        self._status = status
        self.progressHandler = progressHandler
        self.pageQuality = SettingsManager.isDataSavingMode ? "data-saver" : "data"
    }
    
    private func notifyStatusChanged() {
        NotificationCenter.default.post(
            name: .downloadStatusChanged,
            object: nil,
            userInfo: nil)
    }
    
    func fetchPageUrlsIfNeeded() async {
        guard pageURLs.isEmpty else { return }
        do {
            let pagesModel = try await Requests.Chapter.getPages(chapterId: id).value
            pageURLs = pagesModel.pageURLs
            totalPages = pagesModel.pageURLs.count
        } catch {
            print("Error fetching pages:", error)
        }
    }
    
    func cancel(mangaDir: URL) {
        tasks.forEach { $0.cancel() }
        let fileManager = FileManager.default
        let mangaFolder = mangaDir.appending(path: mangaModel.id)
        let chapterFolder = mangaFolder.appending(path: chapterModel.id)
        try? fileManager.removeItem(at: chapterFolder)
    }
    
    func toPersistentData() -> ChapterDownloadData {
        return ChapterDownloadData(
            chapterID: id,
            mangaID: mangaModel.id,
            pageURLs: pageURLs,
            remainingPages: tasks.compactMap { $0.originalRequest?.url },
            pageQuality: pageQuality,
            totalPages: totalPages,
            completedPages: completedPages,
            status: status,
            progress: progress)
    }
    
    static func fromPersistentData(_ data: ChapterDownloadData, mangaModel: MangaModel, chapterModel: ChapterModel, session: URLSession) -> ChapterDownload {
        let download = ChapterDownload(
            mangaModel: mangaModel,
            chapterModel: chapterModel,
            pageURLs: data.pageURLs,
            status: .paused)
        download.pageQuality = data.pageQuality
        download.totalPages = data.totalPages
        download.completedPages = data.completedPages
        download.progress = data.progress
        for remainingPage in data.remainingPages {
            let task = session.downloadTask(with: remainingPage)
            download.tasks.append(task)
        }
        return download
    }
}
