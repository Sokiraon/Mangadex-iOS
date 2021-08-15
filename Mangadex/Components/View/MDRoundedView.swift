//
//  MDRoundedView.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/15.
//

import Foundation
import UIKit

class MDRoundedView: UIView {
    
    private var roundedCorners: UIRectCorner!
    
    convenience init(roundedCorners: UIRectCorner) {
        self.init()
        self.roundedCorners = roundedCorners
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
