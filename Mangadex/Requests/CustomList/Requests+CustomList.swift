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
            let json = try await Requests.get(url: .mainHost("/list/\(id)"))
            guard let data = json["data"],
                  let model = CustomListModel.yy_model(withJSON: data) else {
                throw Errors.IllegalData
            }
            return model
        }
    }
}
