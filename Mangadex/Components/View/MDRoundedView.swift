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
    private var cornerRadius: CGFloat!
    
    convenience init(roundedCorners: UIRectCorner, cornerRadius: CGFloat = 10) {
        self.init()
        self.roundedCorners = roundedCorners
        self.cornerRadius = cornerRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskPath = UIBezierPath.init(
            roundedRect: bounds,
            byRoundingCorners: roundedCorners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
