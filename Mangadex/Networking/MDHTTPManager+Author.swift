//
//  MDHTTPManager+Author.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/19.
//

import Foundation
import SwiftyJSON

extension MDHTTPManager {
    func getAuthorNameById(_ authorId: String,
                           onSuccess success: @escaping (_ name: String) -> Void,
                           onError error: (() -> Void)? = nil) {
        self.get("/author/\(authorId)",
                 ofType: HostType.HostTypeApi,
                 withParams: [:]) { json in
            let data = JSON(json)
            success(data["data"]["attributes"]["name"].string!)
        } onError: {
            if (error != nil) {
                error!()
            }
        }
    }
}
