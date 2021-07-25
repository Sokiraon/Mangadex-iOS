//
// Created by John Rion on 2021/7/3.
//

import Foundation
import UIKit

extension UIButton {
    convenience init(handler: @escaping () -> Void, title: String = "", titleColor: UIColor, backgroundColor: UIColor? = nil) {
        self.init()
        addAction(UIAction(handler: { action in
            handler()
        }), for: .touchUpInside)
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
    }
}
