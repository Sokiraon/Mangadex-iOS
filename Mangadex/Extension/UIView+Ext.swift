//
// Created by John Rion on 2021/7/18.
//

import Foundation
import UIKit

enum ViewStyle {
    case line
}

extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
    
    convenience init(style: ViewStyle) {
        self.init()
        
        switch style {
        case .line:
            backgroundColor = .grayDFDFDF
            self.snp.makeConstraints { make in
                make.height.equalTo(0.5)
            }
            break
        }
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
