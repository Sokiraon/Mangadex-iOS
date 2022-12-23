//
//  Array.swift
//  Mangadex
//
//  Created by John Rion on 12/20/22.
//

import Foundation

extension Array {
    /// Retrieve element from the array for a given index.
    ///
    /// If index is out of bound, returns nil.
    func get(_ i: Index) -> Element? {
        return (i >= 0 && i < count) ? self[i] : nil
    }
}
