//
//  UserModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/21.
//

import Foundation

struct UserAttributes: Codable {
    let username: String
    var roles = [String]()
}

struct UserModelEssential: Codable {
    let id: String
    let type: String
    let attributes: UserAttributes?
}
