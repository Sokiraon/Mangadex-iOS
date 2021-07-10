//
// Created by John Rion on 2021/7/10.
//

import Foundation
import YYModel

class MDMangaTagAttributes: NSObject {
    @objc var name: MDMangaMultiLanguageObject!
}

class MDMangaTagDataModel: NSObject {
    @objc var id: String!
    @objc var attributes: MDMangaTagAttributes!
}