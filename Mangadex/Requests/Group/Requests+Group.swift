//
//  Requests+Group.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/05.
//

import Foundation

extension Requests {
    enum Group {
        static func query(params: [String: Any] = [:]) async throws -> GroupCollection {
            let defaultParams: [String: Any] = [
                "limit": 15,
                "includes[]": "leader"
            ]
            let params = defaultParams + params
            let model = try await Requests.get(
                url: .mainHost("/group"),
                params: params,
                as: GroupCollection.self
            )
            return model
        }
    }
}
