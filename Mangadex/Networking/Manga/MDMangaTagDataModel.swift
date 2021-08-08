//
// Created by John Rion on 2021/7/10.
//

import Foundation
import YYModel

class MDMangaTagAttributes: NSObject {
    @objc var name: MDMangaMultiLanguageObject!
    
    func localizedName() -> String {
        let original = name.localizedString()
        guard let key = MDMangaTagReflecter[original] else {
            return original
        }
        let localized = key.localized()
        if (localized == key) {
            return original
        }
        return localized
    }
}

class MDMangaTagDataModel: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaTagAttributes!
}

fileprivate let MDMangaTagReflecter = [
    "Reincarnation": "kTagReincarnation",
    "Action": "kTagAction",
    "Demons": "kTagDemons",
    "Comedy": "kTagComedy",
    "Martial Arts": "kTagMartial",
    "Magic": "kTagMagic",
    "Harem": "kTagHarem",
    "Isekai": "kTagIsekai",
    "Drama": "kTagDrama",
    "School Life": "kTagSchool",
    "Fantasy": "kTagFantasy",
    "Romance": "kTagRomance",
    "Slice of Life": "kTagLife",
    "Award Winning": "kTagAward",
    "Adaptation": "kTagAdaptation",
    "Long Strip": "kTagLongStrip",
    "Monsters": "kTagMonsters",
    "Samurai": "kTagSamurai",
    "Sci-Fi": "kTagSciFi",
    "Superhero": "kTagSuperhero",
    "Gore": "kTagGore",
    "Supernatural": "kTagSupernatural",
]
