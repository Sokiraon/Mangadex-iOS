//
// Created by John Rion on 2021/7/18.
//

import Foundation
import UIKit

extension UIScrollView {
    
    enum ScrollDirection {
        case horizontal
        case vertical
        case none
    }
    
    convenience init(bounce: ScrollDirection = .none, showIndicator: Bool = true) {
        self.init()
        
        if (bounce == .horizontal) {
            alwaysBounceHorizontal = true
        } else if (bounce == .vertical) {
            alwaysBounceVertical = true
        }
        
        showsHorizontalScrollIndicator = showIndicator
        showsVerticalScrollIndicator = showIndicator
    }
}
