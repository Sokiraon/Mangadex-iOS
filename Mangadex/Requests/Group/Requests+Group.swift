//
//  Requests+Group.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/05.
//

import Foundation
import PromiseKit

extension Requests {
    enum Group {
        static func query(params: [String: Any] = [:]) -> Promise<GroupCollection> {
            let defaultParams: [String: Any] = [
                "limit": 15,
                "includes[]": "leader"
            ]
            let params = defaultParams + params
            return Promise { seal in
                firstly {
                    Requests.get(path: "/group", params: params)
                }.done { json in
                    guard let model = GroupCollection.yy_model(withJSON: json) else {
                        seal.reject(Errors.IllegalData)
                        return
                    }
                    seal.fulfill(model)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
