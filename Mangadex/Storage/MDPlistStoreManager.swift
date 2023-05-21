//
//  MDPlistStoreManager.swift
//  Mangadex
//
//  Created by John Rion on 2021/7/25.
//

import Foundation

/** Enumeration for plist file names */
enum PlistNames: String {
    case mangaProgress = "com.mangadex.mangaReadHistory.plist"
}

class MDPlistStoreManager {
    
    static func loadDict(fromFile file: PlistNames) -> [String: String]? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = "\(paths.first!)/\(file.rawValue)"
        if let xml = FileManager.default.contents(atPath: path) {
            return (try? PropertyListSerialization.propertyList(
                        from: xml, options: .mutableContainersAndLeaves, format: nil)
            ) as? [String: String]
        }
        return nil
    }
    
    static func get(forKey key: String, fromFile file: PlistNames) -> String? {
        guard let dict = loadDict(fromFile: file) else {
            return nil
        }
        
        return dict[key]
    }
    
    static func save(withKey key: String, value: String, toFile file: PlistNames) -> Bool {
        var dict = loadDict(fromFile: file)
        if (dict == nil) {
            dict = [:]
        }
        
        dict![key] = value
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(file.rawValue)
        
        do {
            let data = try encoder.encode(dict)
            try data.write(to: path)
            
            return true
        } catch {
            return false
        }
    }
}
