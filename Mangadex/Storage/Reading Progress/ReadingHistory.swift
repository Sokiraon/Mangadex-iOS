//
//  ReadingHistory.swift
//  Mangadex
//
//  Created by John Rion on 2025/12/15.
//

import SwiftData
import Foundation

@Model
final class ReadingHistory {
    @Attribute(.unique)
    var mangaId: String
    
    var mangaTitle: String
    var coverURL: URL?
    var chapterId: String
    var chapterTitle: String
    var pageIndex: Int
    var updatedAt: Date
    
    init(
        mangaId: String,
        mangaTitle: String,
        coverURL: URL? = nil,
        chapterId: String,
        chapterTitle: String,
        pageIndex: Int,
        updatedAt: Date = .now
    ) {
        self.mangaId = mangaId
        self.mangaTitle = mangaTitle
        self.coverURL = coverURL
        self.chapterId = chapterId
        self.chapterTitle = chapterTitle
        self.pageIndex = pageIndex
        self.updatedAt = updatedAt
    }
}

struct ReadingHistoryDTO: Sendable {
    let mangaId: String
    let mangaTitle: String
    let coverURL: URL?
    let chapterId: String
    let chapterTitle: String
    let pageIndex: Int
    let updatedAt: Date
    
    init(
        mangaId: String,
        mangaTitle: String,
        coverURL: URL?,
        chapterId: String,
        chapterTitle: String,
        pageIndex: Int,
        updatedAt: Date
    ) {
        self.mangaId = mangaId
        self.mangaTitle = mangaTitle
        self.coverURL = coverURL
        self.chapterId = chapterId
        self.chapterTitle = chapterTitle
        self.pageIndex = pageIndex
        self.updatedAt = updatedAt
    }
    
    init(from history: ReadingHistory) {
        self.init(
            mangaId: history.mangaId,
            mangaTitle: history.mangaTitle,
            coverURL: history.coverURL,
            chapterId: history.chapterId,
            chapterTitle: history.chapterTitle,
            pageIndex: history.pageIndex,
            updatedAt: history.updatedAt
        )
    }
}
