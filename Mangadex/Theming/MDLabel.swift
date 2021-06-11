//
//  MDLabel.swift
//  Mangadex
//
//  Created by edz on 2021/6/9.
//

import Foundation
import UIKit

extension UILabel {
    static func initWithText(_ text: String,
                             fontSize size: CGFloat,
                             fontWeight weight: UIFont.Weight,
                             textColor color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        label.textColor = color
        return label
    }
}
