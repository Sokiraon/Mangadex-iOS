//
//  MDHTTPManager+User.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation

extension MDHTTPManager {
    func getUserFollowedMangas(params: [String: Any],
                               onSuccess success: @escaping (_ data: Array<MangaItem>) -> Void,
                               onError error: @escaping () -> Void) {
        MDUserManager.getInstance()
            .getValidatedToken { token in
                self.get("/user/follows/manga",
                         ofType: .HostTypeApi,
                         withParams: params,
                         token: token) { json in
                    var result: Array<MangaItem> = []
                    let mangaList = NSArray.yy_modelArray(with: MDMangaItemDataModel.classForCoder(),
                                                          json: json["results"] as! Array<[String : Any]>)
                    for manga in mangaList as! Array<MDMangaItemDataModel> {
                        result.append(MangaItem(model: manga))
                    }
                    success(result)
                } onError: { 
                    error()
                }

            } onError: {
                error()
            }
    }
}
