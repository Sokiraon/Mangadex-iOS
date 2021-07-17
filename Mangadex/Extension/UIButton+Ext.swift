//
// Created by John Rion on 2021/7/3.
//

import Foundation
import UIKit

extension UIButton {
    static func initWithTitle(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        return button
    }
}