//
// Created by John Rion on 7/22/22.
//

import Foundation
import PromiseKit
import SwiftyJSON

extension MDRequests {
    enum Manga {
        static func query(params: [String: Any] = [:]) -> Promise<[MangaItem]> {
            Promise { seal in
                firstly {
                    MDRequests.get(path: "/manga", host: .main, params: params)
                }
                    .done { json in
                        guard let data = json["data"] as? Array<[String: Any]> else {
                            seal.reject(MDRequests.DefaultError)
                            return
                        }
                        let itemModels = NSArray.yy_modelArray(with: MDMangaItemDataModel.classForCoder(), json: data)
                        if let items = itemModels as? [MDMangaItemDataModel] {
                            seal.fulfill(items.map { MangaItem.init(model: $0)})
                        }
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            }
        }
        
        static func getCoverUrl(coverId: String, mangaId: String) -> Promise<URL> {
            Promise { seal in
                firstly {
                    MDRequests.get(path: "/cover/\(coverId)", host: .main)
                }
                    .done { json in
                        let data = JSON(json)
                        if let filename = data["data"]["attributes"]["fileName"].string {
                            let coverUrl = "\(HostUrl.uploads.rawValue)/covers/\(mangaId)/\(filename).256.jpg"
                            seal.fulfill(URL(string: coverUrl)!)
                        }
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            }
        }
    }
}
