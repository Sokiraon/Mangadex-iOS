//
//  MDHTTPManager+Chapter.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import SwiftyJSON
import YYModel

enum Order: String {
    case ASC = "asc"
    case DESC = "desc"
}

extension MDHTTPManager {
    func getChaptersByMangaId(_ mangaId: String,
                              offset: Int,
                              locale: String,
                              order: Order,
                              onSuccess success: @escaping (_ models: [MDMangaChapterDataModel], _ total: Int) -> Void,
                              onError error: (() -> Void)? = nil) {
        self.get("/manga/\(mangaId)/feed",
                 ofType: .HostTypeApi,
                 withParams: [
                     "offset": offset,
                     "translatedLanguage[]": locale,
                     "order[chapter]": order.rawValue
                 ]) { json in
            let total = json["total"] as! Int
            let results = json["results"] as! Array<[String: Any]>
            let models = NSArray.yy_modelArray(with: MDMangaChapterDataModel.classForCoder(), json: results)
            success(models as! [MDMangaChapterDataModel], total)
        } onError: {
            if (error != nil) {
                error!()
            }
        }
    }
    
    func getChapterBaseUrlById(_ id: String,
                               onSuccess success: @escaping (_ url: String) -> Void,
                               onError error: (() -> Void)? = nil) {
        self.get("/at-home/server/\(id)",
                 ofType: .HostTypeApi,
                 withParams: [:]) { result in
            let json = JSON(result)
            if let url = json["baseUrl"].string {
                success(url)
            }
        } onError: {
            if (error != nil) {
                error!()
            }
        }
    }
}
