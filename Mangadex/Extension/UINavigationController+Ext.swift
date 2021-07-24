//
// Created by John Rion on 2021/7/18.
//

import Foundation
import UIKit

fileprivate let kCATransitionDurationShort = 0.3

enum UIViewControllerPushAnimation {
    case leftIn
    case rightIn
}

extension UINavigationController {
    func setPushAnimation(_ animation: UIViewControllerPushAnimation) {
        let transition = CATransition()
        transition.duration = kCATransitionDurationShort
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
    
    func replaceTopViewController(with vc: UIViewController, animated: Bool = true) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = vc
        setViewControllers(vcs, animated: animated)
    }
    
    func replaceTopViewController(with vc: UIViewController, animation: UIViewControllerPushAnimation) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = vc
        setPushAnimation(animation)
        setViewControllers(vcs, animated: false)
    }
    
    func pushViewController(_ vc: UIViewController, animation: UIViewControllerPushAnimation) {
        setPushAnimation(animation)
        pushViewController(vc, animated: false)
    }
}
