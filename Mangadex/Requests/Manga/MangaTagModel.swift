//
// Created by John Rion on 2021/7/10.
//

import Foundation

struct MangaTagAttributes: Codable {
    let name: MangaMultiLangObj
    let group: String
}

struct MangaTagModel: Codable {
    let id: String
    let attributes: MangaTagAttributes
    
    func localizedName() -> String? {
        return attributes.name.en?.localized()
    }
}

extension Array where Element == MangaTagModel {
    var genres: Self {
        filter { tagModel in
            tagModel.attributes.group == "genre"
        }
    }
    
    var themes: Self {
        filter { tagModel in
            tagModel.attributes.group == "theme"
        }
    }
}
