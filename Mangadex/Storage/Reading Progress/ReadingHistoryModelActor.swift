//
//  ReadingHistoryModelActor.swift
//  Mangadex
//
//  Created by John Rion on 2025/12/15.
//

import SwiftData
import Foundation

@ModelActor
actor ReadingHistoryModelActor {
    func upsert(data: ReadingHistoryDTO) throws {
        let mangaId = data.mangaId
        let descriptor = FetchDescriptor<ReadingHistory>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        
        if let history = try modelContext.fetch(descriptor).first {
            history.chapterId = data.chapterId
            history.chapterTitle = data.chapterTitle
            history.pageIndex = data.pageIndex
            history.updatedAt = .now
        } else {
            let history = ReadingHistory(
                mangaId: data.mangaId,
                mangaTitle: data.mangaTitle,
                coverURL: data.coverURL,
                chapterId: data.chapterId,
                chapterTitle: data.chapterTitle,
                pageIndex: data.pageIndex
            )
            modelContext.insert(history)
        }
        
        try modelContext.save()
    }
    
    func history(for mangaId: String) throws -> ReadingHistoryDTO? {
        let descriptor = FetchDescriptor<ReadingHistory>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        return try modelContext.fetch(descriptor).first.map {
            ReadingHistoryDTO(from: $0)
        }
    }

    func deleteHistory(for mangaId: String) throws {
        let descriptor = FetchDescriptor<ReadingHistory>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        guard let history = try modelContext.fetch(descriptor).first else {
            return
        }
        modelContext.delete(history)
        try modelContext.save()
    }
    
    func fetchHistories(limit: Int = 20, offset: Int = 0) throws -> [ReadingHistoryDTO] {
        var descriptor = FetchDescriptor<ReadingHistory>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        return try modelContext.fetch(descriptor).map {
            ReadingHistoryDTO(from: $0)
        }
    }
}
