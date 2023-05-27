//
// Created by John Rion on 2021/7/18.
//

import Foundation
import UIKit

extension UINavigationController {
    enum TransitionAnimation {
        case leftIn, rightIn
    }
    
    func setTransitionAnimation(_ animation: TransitionAnimation, duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        switch animation {
        case .leftIn:
            transition.subtype = .fromLeft
        case .rightIn:
            transition.subtype = .fromRight
        }
        view.layer.add(transition, forKey: nil)
    }
    
    func replaceTopViewController(with viewController: UIViewController, animated: Bool = true) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = viewController
        setViewControllers(vcs, animated: animated)
    }
    
    func replaceTopViewController(
        with viewController: UIViewController,
        using animation: TransitionAnimation
    ) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = viewController
        setTransitionAnimation(animation)
        setViewControllers(vcs, animated: false)
    }
    
    func pushViewController(
        _ viewController: UIViewController,
        using animation: TransitionAnimation
    ) {
        setTransitionAnimation(animation)
        pushViewController(viewController, animated: false)
    }
}
