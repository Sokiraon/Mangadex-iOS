//
//  ChapterStatisticsModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/2/25.
//

import Foundation
import YYModel

class ChapterStatisticsComment: NSObject {
    @objc var threadId: Int = 0
    @objc var repliesCount: Int = 0
}

class ChapterStatisticsModel: NSObject, YYModel {
    @objc var comments: ChapterStatisticsComment?
    
    convenience init(threadId: Int, repliesCount: Int) {
        self.init()
        self.comments = ChapterStatisticsComment()
        self.comments?.threadId = threadId
        self.comments?.repliesCount = repliesCount
    }
}
