//
//  SubString.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/08.
//

import Foundation

extension String {
    subscript(range: ClosedRange<Int>) -> String {
        get {
            var lowerBound: Index
            if range.lowerBound >= 0 {
                lowerBound = index(startIndex, offsetBy: range.lowerBound)
            } else {
                lowerBound = index(endIndex, offsetBy: range.lowerBound)
            }
            var upperBound: Index
            if range.upperBound >= 0 {
                upperBound = index(startIndex, offsetBy: range.upperBound)
            } else {
                upperBound = index(endIndex, offsetBy: range.upperBound)
            }
            return String(self[lowerBound...upperBound])
        }
    }
    
    subscript(rangeFrom: PartialRangeFrom<Int>) -> String {
        get {
            var lowerBound = rangeFrom.lowerBound
            if lowerBound < 0 {
                lowerBound += count - 1
            }
            return self[lowerBound...count-1]
        }
    }
    
    subscript(rangeUpTo: PartialRangeUpTo<Int>) -> String {
        get {
            var upperBound = rangeUpTo.upperBound
            if upperBound < 0 {
                upperBound += count - 1
            }
            return self[0...upperBound-1]
        }
    }
    
    subscript(rangeThrough: PartialRangeThrough<Int>) -> String {
        get {
            var upperBound = rangeThrough.upperBound
            if upperBound < 0 {
                upperBound += count - 1
            }
            return self[0...upperBound]
        }
    }
}
