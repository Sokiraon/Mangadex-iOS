//
//  ChapterPagesModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/21.
//

import Foundation

struct ChapterPages: Codable {
    let hash: String
    let data: [String]
    let dataSaver: [String]
}

struct ChapterPagesModel: Codable {
    let baseUrl: String
    let chapter: ChapterPages
    
    var pageURLs: [URL] {
        if SettingsManager.isDataSavingMode {
            return chapter.dataSaver.map { fileName in
                URL(string: "\(baseUrl)/data-saver/\(chapter.hash)/\(fileName)")!
            }
        } else {
            return chapter.data.map { fileName in
                URL(string: "\(baseUrl)/data/\(chapter.hash)/\(fileName)")!
            }
        }
    }
}
