//
// Created by John Rion on 2021/7/18.
//

import Foundation
import UIKit

extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
    
    static func +++ (superview: UIView, subview: UIView) {
        superview.addSubview(subview)
    }
    
    static func +++ (superview: UIView, subviews: [UIView]) {
        for view in subviews {
            superview.addSubview(view)
        }
    }
    
    static func +++ (superview: UIView, layoutGuide: UILayoutGuide) {
        superview.addLayoutGuide(layoutGuide)
    }
}
