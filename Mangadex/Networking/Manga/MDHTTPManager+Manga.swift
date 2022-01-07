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
                                onSuccess success: @escaping (_ data: [MangaItem]) -> Void,
                                onError error: (() -> Void)? = nil) {
        self.get("/manga", ofType: .HostTypeApi, withParams: params) { json in
            guard let data = json["data"] as? Array<[String: Any]> else {
                error?()
                return
            }
            let mangaModels = NSArray.yy_modelArray(with: MDMangaItemDataModel.classForCoder(), json: data)
            if (mangaModels != nil) {
                success((mangaModels as! [MDMangaItemDataModel]).map {
                    MangaItem.init(model: $0)
                })
            }
        } onError: {
            error?()
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
                let coverUrl = "\(HostType.HostTypeUploads.rawValue)/covers/\(mangaId)/\(filename).256.jpg"
                success(URL(string: coverUrl)!)
            }
        } onError: {
            if (error != nil) {
                error!()
            }
        }
    }
}
