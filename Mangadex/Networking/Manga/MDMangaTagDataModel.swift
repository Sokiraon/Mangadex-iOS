//
// Created by John Rion on 2021/7/10.
//

import Foundation
import YYModel

class MDMangaTagAttributes: NSObject {
    @objc var name: MDMangaMultiLanguageObject!
    
    func localizedName() -> String {
        return name.en?.localized() ?? ""
    }
}

class MDMangaTagDataModel: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaTagAttributes!
}
