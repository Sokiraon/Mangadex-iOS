//
//  Requests+CustomList.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation
import PromiseKit

extension Requests {
    enum CustomList {
        static func get(id: String) -> Promise<CustomListModel> {
            Promise { seal in
                firstly {
                    Requests.get(path: "/list/\(id)")
                }.done { json in
                    if let model = CustomListModel.yy_model(withJSON: json["data"]!) {
                        seal.fulfill(model)
                        return
                    }
                    seal.reject(Errors.IllegalData)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
