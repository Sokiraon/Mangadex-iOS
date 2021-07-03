//
//  UILabel+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

extension UILabel {
    
    static func initWithText(_ text: String,
                             ofFontWeight weight: UIFont.Weight,
                             andSize size: CGFloat,
                             scalable: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        label.adjustsFontSizeToFitWidth = scalable
        label.minimumScaleFactor = (size - 2) / size
        return label
    }
}
