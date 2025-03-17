//
//  ChapterDownloadData.swift
//  Mangadex
//
//  Created by John Rion on 2025/03/18.
//

import Foundation
import SwiftData

@Model
class ChapterDownloadData {
    @Attribute(.unique) var chapterID: String
    var mangaID: String
    
    var pageURLs: [URL]
    var remainingPages: [URL]
    var pageQuality: String
    
    var totalPages: Int
    var completedPages: Int
    
    var status: ChapterDownload.Status
    var progress: Double
    
    init(chapterID: String, mangaID: String, pageURLs: [URL], remainingPages: [URL], pageQuality: String, totalPages: Int, completedPages: Int, status: ChapterDownload.Status, progress: Double) {
        self.chapterID = chapterID
        self.mangaID = mangaID
        self.pageURLs = pageURLs
        self.remainingPages = remainingPages
        self.pageQuality = pageQuality
        self.totalPages = totalPages
        self.completedPages = completedPages
        self.status = status
        self.progress = progress
    }
}
