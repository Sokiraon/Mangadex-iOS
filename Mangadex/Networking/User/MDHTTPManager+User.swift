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
        MDUser.getInstance()
            .getValidatedToken { token in
                self.get("/user/follows/manga",
                         ofType: .HostTypeApi,
                         withParams: params,
                         token: token) { json in
                    var result: Array<MangaItem> = []
                    let mangaList = NSArray.yy_modelArray(with: MDMangaItemDataModel.classForCoder(),
                                                          json: json["results"] as! Array<[String : Any]>)
                    for manga in mangaList as! Array<MDMangaItemDataModel> {
                        var authorId = "", artistId = "", coverId = ""
                        for relationship in manga.relationships {
                            switch relationship.type {
                            case "author":
                                authorId = relationship.id
                                break
                            case "artist":
                                artistId = relationship.id
                                break
                            case "cover_art":
                                coverId = relationship.id
                                break
                            default:
                                break
                            }
                        }
                        result.append(
                            MangaItem(
                                id: manga.data.id,
                                title: manga.data.attributes.title.en,
                                authorId: authorId,
                                artistId: artistId,
                                coverId: coverId
                            )
                        )
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
