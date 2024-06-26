//
//  Dictionary+Ext.swift
//  Mangadex
//
//  Created by John Rion on 12/18/22.
//

import Foundation

extension Dictionary {
    func contains(_ key: Key) -> Bool {
        contains { $0.key == key }
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs) { _, new in
            new
        }
    }
}
