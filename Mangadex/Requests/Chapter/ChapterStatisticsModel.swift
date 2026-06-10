//
//  ChapterStatisticsModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/2/25.
//

import Foundation

struct ChapterStatisticsComment: Codable {
    var threadId: Int = 0
    var repliesCount: Int = 0
}

struct ChapterStatisticsModel: Codable {
    var comments: ChapterStatisticsComment?
    
    init(threadId: Int, repliesCount: Int) {
        self.comments = ChapterStatisticsComment(
            threadId: threadId,
            repliesCount: repliesCount
        )
    }
}
