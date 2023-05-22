//
// Created by John Rion on 2021/7/10.
//

import Foundation
import YYModel

class MDMangaTagAttributes: NSObject {
    @objc var name: MangaMultiLanguageObject!
    @objc var group: String!
}

class MDMangaTagDataModel: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaTagAttributes!
    
    func localizedName() -> String? {
        return attributes.name.en?.localized()
    }
}
