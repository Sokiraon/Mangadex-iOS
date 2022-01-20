//
//  UIEdgeInsets+Ext.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit

extension UIEdgeInsets {

    static func all(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: value, bottom: value, right: value)
    }
    
    static func top(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: 0, bottom: 0, right: 0)
    }
    
    static func left(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: value, bottom: 0, right: 0)
    }
    
    static func bottom(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: 0, bottom: value, right: 0)
    }
    
    static func right(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: 0, bottom: 0, right: value)
    }
    
    static func cssStyle(_ values: CGFloat...) -> UIEdgeInsets {
        switch values.count {
        case 0:
            return .all(0)
        case 1:
            return .all(values[0])
        case 2:
            return .init(top: values[0], left: values[1], bottom: values[0], right: values[1])
        case 3:
            return .init(top: values[0], left: values[1], bottom: values[2], right: values[1])
        default:
            return .init(top: values[0], left: values[3], bottom: values[2], right: values[1])
        }
    }
}
