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
    
    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: value, bottom: 0, right: value)
    }
    
    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: 0, bottom: value, right: 0)
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

extension NSDirectionalEdgeInsets {

    static func all(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: value, leading: value, bottom: value, trailing: value)
    }

    static func horizontal(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: value, bottom: 0, trailing: value)
    }

    static func vertical(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: value, leading: 0, bottom: value, trailing: 0)
    }

    static func top(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: value, leading: 0, bottom: 0, trailing: 0)
    }

    static func leading(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: value, bottom: 0, trailing: 0)
    }

    static func left(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .leading(value)
    }

    static func bottom(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: 0, bottom: value, trailing: 0)
    }

    static func trailing(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: 0, leading: 0, bottom: 0, trailing: value)
    }

    static func right(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .trailing(value)
    }

    static func cssStyle(_ values: CGFloat...) -> NSDirectionalEdgeInsets {
        switch values.count {
        case 0:
            return .all(0)
        case 1:
            return .all(values[0])
        case 2:
            return .init(top: values[0], leading: values[1], bottom: values[0], trailing: values[1])
        case 3:
            return .init(top: values[0], leading: values[1], bottom: values[2], trailing: values[1])
        default:
            return .init(top: values[0], leading: values[3], bottom: values[2], trailing: values[1])
        }
    }
}
