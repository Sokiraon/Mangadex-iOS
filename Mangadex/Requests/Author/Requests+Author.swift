//
//  Requests+Author.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation
import SwiftyJSON

extension Requests {
    enum Author {
        static func get(id: String) async throws -> AuthorModel {
            let res = try await Requests.get(url: .mainHost("/author/\(id)"))
            let json = JSON(res)
            if let model = AuthorModel.yy_model(withJSON: json["data"].rawValue) {
                return model
            } else {
                throw Errors.IllegalData
            }
        }
        
        static func query(params: [String: Any] = [:]) async throws -> AuthorCollection {
            let defaultParams: [String: Any] = [ "limit": 20 ]
            let params = defaultParams + params
            let res = try await Requests.get(url: .mainHost("/author"), params: params)
            if let model = AuthorCollection.yy_model(withJSON: res) {
                return model
            } else {
                throw Errors.IllegalData
            }
        }
    }
}
