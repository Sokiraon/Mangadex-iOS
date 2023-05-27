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


// Add a Kotlin-style "apply" function to NSObject
protocol HasApply { }

extension HasApply {
    func apply(closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: HasApply {}
