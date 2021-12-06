//
//  MDHTTPManager+Manga.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import SwiftyJSON

extension MDHTTPManager {
    func getMangaListWithParams(_ params: [String: Any],
                                onSuccess success: @escaping (_ data: Array<MangaItem>) -> Void,
                                onError error: (() -> Void)? = nil) {
        self.get("/manga", ofType: .HostTypeApi, withParams: params) { json in
            var result: Array<MangaItem> = []
            let mangaList = NSArray.yy_modelArray(with: MDMangaItemDataModel.classForCoder(),
                                                  json: json["data"] as! Array<[String : Any]>)
            for manga in mangaList as! Array<MDMangaItemDataModel> {
                result.append(MangaItem(model: manga))
            }
            success(result)
        } onError: {
            if (error != nil) {
                error!()
            }
        }
    }
    
    func getMangaChaptersById(_ mangaId: String,
                              onSuccess success: @escaping (_ volumes: MDMangaVolumesDataModel) -> Void,
                              onError error: (() -> Void)? = nil) {
        self.get("/manga/\(mangaId)/aggregate", ofType: .HostTypeApi, withParams: [:]) { json in
            let mangaVolumes = MDMangaVolumesDataModel.yy_model(with: json)
            success(mangaVolumes!)
        } onError: {
            if (error != nil) {
                error!()
            }
        }
    }
    
    func getMangaCoverUrlById(_ coverId: String,
                              forManga mangaId: String,
                              onSuccess success: @escaping (_ coverUrl: URL) -> Void,
                              onError error: (() -> Void)? = nil) {
        self.get("/cover/\(coverId)", ofType: .HostTypeApi, withParams: [:]) { json in
            let data = JSON(json)
            if let filename = data["data"]["attributes"]["fileName"].string {
                let coverUrl = "\(HostType.HostTypeUploads.rawValue)/covers/\(mangaId)/\(filename)"
                success(URL(string: coverUrl)!)
            }
        } onError: {
            if (error != nil) {
                error!()
            }
        }
    }
}
