//
//  String+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/9.
//

import Foundation

extension Optional where Wrapped == String {
    /**
     A Boolean value indicating whether an Optional string is nil or has no characters.
     */
    var isBlank: Bool {
        self == nil || self!.isEmpty
    }
}
