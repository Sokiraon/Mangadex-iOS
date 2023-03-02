//
//  MDChapterStatisticsModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/2/25.
//

import Foundation
import YYModel

class MDChapterStatComment: NSObject {
    @objc var threadId: Int = 0
    @objc var repliesCount: Int = 0
}

class MDChapterStatistics: NSObject, YYModel {
    @objc var comments: MDChapterStatComment?
    
    convenience init(threadId: Int, repliesCount: Int) {
        self.init()
        self.comments = MDChapterStatComment()
        self.comments?.threadId = threadId
        self.comments?.repliesCount = repliesCount
    }
}
