//
//  Requests+CustomList.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation

extension Requests {
    enum CustomList {
        static func get(id: String) async throws -> CustomListModel {
            let response = try await Requests.get(
                url: .mainHost("/list/\(id)"),
                as: DataResponse<CustomListModel>.self
            )
            return response.data
        }
    }
}
