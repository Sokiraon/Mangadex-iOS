//
//  MDHTTPManager+Chapter.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import SwiftyJSON

extension MDHTTPManager {
    func getChapterIdByMangaId(_ mangaId: String,
                               volume: String,
                               chapter: String,
                               onSuccess success: @escaping (_ model: MDMangaChapterDataModel) -> Void,
                               onError error: (() -> Void)? = nil) {
        self.get("/chapter",
                 ofType: .HostTypeApi,
                 withParams: ["manga": mangaId, "volume": volume, "chapter": chapter]) { json in
            let results = json["results"] as! Array<[String: Any]>
            let data = results[0]["data"] as! [String: Any]
            let model = MDMangaChapterDataModel.yy_model(with: data)
            success(model!)
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
