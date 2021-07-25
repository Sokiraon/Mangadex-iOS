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
        return MDPlistStoreManager.get(forKey: id, fromFile: .mangaProgress)
    }
    
    static func saveProgress(_ progress: String, forMangaId id: String) {
        _ = MDPlistStoreManager.save(withKey: id, value: progress, toFile: .mangaProgress)
    }
}
