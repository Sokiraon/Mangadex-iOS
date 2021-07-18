//
// Created by John Rion on 2021/7/18.
//

import Foundation
import UIKit

extension UINavigationController {
    func replaceTopViewController(with vc: UIViewController, animated: Bool = true) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = vc
        setViewControllers(vcs, animated: animated)
    }
}