//
//  Requests+Author.swift
//  Mangadex
//
//  Created by John Rion on 9/2/22.
//

import Foundation

extension Requests {
    enum Author {
        static func get(id: String) async throws -> AuthorModel {
            let res = try await Requests.get(
                url: .mainHost("/author/\(id)"),
                as: DataResponse<AuthorModel>.self
            )
            return res.data
        }
        
        static func query(params: [String: Any] = [:]) async throws -> AuthorCollection {
            let defaultParams: [String: Any] = [ "limit": 20 ]
            let params = defaultParams + params
            let model = try await Requests.get(
                url: .mainHost("/author"),
                params: params,
                as: AuthorCollection.self
            )
            return model
        }
    }
}
