//
//  MDMangaProgressManager.swift
//  Mangadex
//
//  Created by John Rion on 2021/7/25.
//

import Foundation

/**
 Used for retrieving and saving manga reading progress.
 
 TODO: Add support for multi-language.
 */
class MDMangaProgressManager {
    
    static func retrieveProgress(forMangaId id: String) -> String? {
        MDPlistStoreManager.get(forKey: id, fromFile: .mangaProgress)
    }
    
    static func saveProgress(forMangaId mangaId: String, chapterId: String) {
        _ = MDPlistStoreManager.save(withKey: mangaId, value: chapterId, toFile: .mangaProgress)
    }
}
