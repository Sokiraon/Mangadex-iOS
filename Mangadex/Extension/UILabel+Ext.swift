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
                     color: UIColor = .black2D2E2F,
                     alignment: NSTextAlignment = .left,
                     numberOfLines: Int = 1,
                     scalable: Bool = false) {
        self.init()
        self.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        self.textColor = color
        self.textAlignment = alignment
        self.numberOfLines = numberOfLines
        self.adjustsFontSizeToFitWidth = scalable
        self.minimumScaleFactor = (fontSize - 2) / fontSize
    }
}
