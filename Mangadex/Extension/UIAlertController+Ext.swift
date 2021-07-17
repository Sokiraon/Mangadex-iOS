//
// Created by John Rion on 2021/7/3.
//

import Foundation
import UIKit

struct AlertViewAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
}

extension UIAlertController {
    static func initWithTitle(_ title: String,
                              message: String,
                              style: UIAlertController.Style,
                              actions: AlertViewAction...) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style, handler: action.handler)
            controller.addAction(alertAction)
        }
        return controller
    }
}