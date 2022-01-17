//
//  UIEdgeInsets+Ext.swift
//  Mangadex
//
//  Created by John Rion on 1/15/22.
//

import Foundation
import UIKit

extension UIEdgeInsets {

    /**
     CSS-style initialization method for UIEdgeInsets.
     
     - Parameter value: Collection of inset values to use.
     */
    init(values: [CGFloat]) {
        self.init()
        
        if values.count > 0 {
            switch values.count {
            case 1:
                top = values[0]
                right = values[0]
                bottom = values[0]
                left = values[0]
                break
                
            case 2:
                top = values[0]
                bottom = values[0]
                left = values[1]
                right = values[1]
                break
                
            case 3:
                top = values[0]
                left = values[1]
                right = values[1]
                bottom = values[2]
                break
                
            default:
                top = values[0]
                right = values[1]
                bottom = values[2]
                left = values[3]
                break
            }
        }
    }
}
