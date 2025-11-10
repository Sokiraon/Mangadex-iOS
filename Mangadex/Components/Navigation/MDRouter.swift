//
//  MDRouter.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/15.
//

import Foundation
import UIKit

enum MDShowVCActionType {
    case present, push
}

@MainActor
class MDRouter {
    static let keyWindow = UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .map({ $0 as? UIWindowScene })
        .compactMap({ $0 })
        .first?.windows
        .filter({ $0.isKeyWindow }).first
    
    static var navigationController: MDNavigationController? {
        keyWindow?.rootViewController as? MDNavigationController
    }
    
    static var topViewController: UIViewController? {
        navigationController?.topViewController
    }
    
    static func showVC(_ vc: UIViewController, actionType type: MDShowVCActionType) {
        switch type {
        case .present:
            topViewController?.present(vc, animated: true, completion: nil)
            break
            
        default:
            navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
    
    static func goToLogin() {
        let vc: UIViewController
        if MDKeychain.read().isEmpty {
            vc = MDLoginViewController()
        } else {
            vc = MDPreLoginViewController()
        }
        navigationController?.setViewControllers([vc], animated: true)
    }
}
