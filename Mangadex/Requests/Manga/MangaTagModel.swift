//
// Created by John Rion on 2021/7/10.
//

import Foundation
import YYModel

class MDMangaTagAttributes: NSObject {
    @objc var name: MangaMultiLanguageObject!
    @objc var group: String!
}

class MangaTagModel: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaTagAttributes!
    
    func localizedName() -> String? {
        return attributes.name.en?.localized()
    }
}

extension Array where Element: MangaTagModel {
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
