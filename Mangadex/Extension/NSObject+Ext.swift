//
//  NSObject+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/8.
//

import Foundation

extension NSObject {
    func propertyNames() -> [String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap{ $0.label }
    }
}
