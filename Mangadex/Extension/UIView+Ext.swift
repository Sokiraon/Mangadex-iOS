//
// Created by John Rion on 2021/7/18.
//

import Foundation
import UIKit

enum UIViewStyle {
    case lineHorizontal, lineVertical
}

extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
    
    convenience init(style: UIViewStyle) {
        self.init()
        
        switch style {
        case .lineHorizontal:
            backgroundColor = .grayDFDFDF
            self.snp.makeConstraints { make in
                make.height.equalTo(MDLayout.native1px * 2)
            }
            break
        case .lineVertical:
            backgroundColor = .grayDFDFDF
            self.snp.makeConstraints { make in
                make.width.equalTo(MDLayout.native1px * 2)
            }
        }
    }
}
