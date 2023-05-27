//
//  UIImageView+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

extension UIImage {
    func resized(_ newSize: CGSize) -> UIImage? {
        // Use UIGraphicsBeginImageContextWithOptions here to preserve quality
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: .init(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImageView {
    convenience init(named name: String, color: UIColor? = nil) {
        self.init()
        image = UIImage.init(named: name)
        tintColor = color
    }
}
