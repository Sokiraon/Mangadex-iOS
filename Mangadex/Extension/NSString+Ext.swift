//
// Created by John Rion on 2021/7/17.
//

import Foundation
import UIKit

extension NSString {
    func strHeightWithFont(_ font: UIFont) -> CGFloat {
        let strSize = size(withAttributes: [
            .font: font
        ])
        return strSize.height
    }
    
    func strWidthWithFont(_ font: UIFont) -> CGFloat {
        let strSize = size(withAttributes: [
            .font: font
        ])
        return strSize.width
    }
}
