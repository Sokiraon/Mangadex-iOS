//
//  UIImageView+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

extension UIImageView {
    
    convenience init(imageNamed: String) {
        self.init()
        image = UIImage.init(named: imageNamed)
    }
}
