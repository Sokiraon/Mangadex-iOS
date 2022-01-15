//
//  UIEdgeInsets+Ext.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation

extension UIEdgeInsets {

    init(value: String) {
        self.init()
        let values = value.split(separator: " ")
        if values.count > 0 {
            switch values.count {
            case 1:
                top = Double(values[0])!
                right = Double(values[0])!
                bottom = Double(values[0])!
                left = Double(values[0])!
                break
                
            case 2:
                top = Double(values[0])!
                bottom = Double(values[0])!
                left = Double(values[1])!
                right = Double(values[1])!
                break
                
            case 3:
                top = Double(values[0])!
                left = Double(values[1])!
                right = Double(values[1])!
                bottom = Double(values[2])!
                break
                
            default:
                top = Double(values[0])!
                right = Double(values[1])!
                bottom = Double(values[2])!
                left = Double(values[3])!
                break
            }
        }
    }
}
