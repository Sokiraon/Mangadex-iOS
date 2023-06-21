//
//  UserModel.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/21.
//

import Foundation
import YYModel

class UserAttributes: NSObject, YYModel {
    @objc var username: String!
    @objc var roles = [String]()
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        [ "roles": String.self ]
    }
}

class UserModelEssential: NSObject {
    @objc var id: String!
    @objc var type: String!
    @objc var attributes: UserAttributes?
}
