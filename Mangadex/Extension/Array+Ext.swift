//
//  Array.swift
//  Mangadex
//
//  Created by John Rion on 12/20/22.
//

import Foundation

extension Array {
    func get(_ i: Index) -> Element? {
        return i < count ? self[i] : nil
    }
}
