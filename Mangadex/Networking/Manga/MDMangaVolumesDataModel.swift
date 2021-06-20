//
//  MDMangaVolumesDataModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import YYModel

class MDMangaChapterItem: NSObject {
    @objc var chapter: String!
    var count: Int!
}

class MDMangaVolumeItem: NSObject, YYModel {
    @objc var volume: String!
    var count: Int!
    @objc var chapters: [String: MDMangaChapterItem]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["chapters": MDMangaChapterItem.classForCoder()]
    }
}

class MDMangaVolumesDataModel: NSObject, YYModel {
    @objc var volumes: [String: MDMangaVolumeItem]!
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["volumes": MDMangaVolumeItem.classForCoder()]
    }
}
