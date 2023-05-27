//
// Created by John Rion on 2021/7/3.
//

import Foundation
import UIKit

extension UIButton {
    convenience init(
        title: String = "",
        titleColor: UIColor? = .white,
        backgroundColor: UIColor? = .themePrimary,
        action: UIAction? = nil
    ) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        if let action = action {
            addAction(action, for: .touchUpInside)
        }
    }
}
