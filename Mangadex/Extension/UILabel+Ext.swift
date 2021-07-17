//
//  UILabel+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

extension UILabel {
    
    convenience init(fontSize: CGFloat = 17,
                     fontWeight: UIFont.Weight = .regular,
                     color: Colors = .black2D2E2F,
                     numberOfLines: Int = 1,
                     scalable: Bool = false) {
        self.init()
        self.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        self.textColor = MDColor.get(color)
        self.numberOfLines = numberOfLines
        self.adjustsFontSizeToFitWidth = scalable
        self.minimumScaleFactor = (fontSize - 2) / fontSize
    }
    
    static func initWithFontWeight(_ weight: UIFont.Weight,
                                   andSize size: CGFloat,
                                   scalable: Bool = false) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        label.adjustsFontSizeToFitWidth = scalable
        label.minimumScaleFactor = (size - 2) / size
        return label
    }
    
    static func initWithText(_ text: String,
                             ofFontWeight weight: UIFont.Weight,
                             andSize size: CGFloat,
                             scalable: Bool = false) -> UILabel {
        let label = UILabel.initWithFontWeight(weight, andSize: size, scalable: scalable)
        label.text = text
        return label
    }
}
