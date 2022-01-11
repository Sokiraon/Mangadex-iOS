//
// Created by John Rion on 2022/1/11.
//

import Foundation
import UIKit

class MDTriangleView: UIView {
    
    var color: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .clear
        
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()

        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}
