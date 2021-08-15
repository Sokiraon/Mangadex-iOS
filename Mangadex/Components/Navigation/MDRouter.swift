//
//  MDRouter.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/15.
//

import Foundation

enum MDShowVCActionType {
    case present, push
}

class MDRouter {
    static let keyWindow = UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .map({ $0 as? UIWindowScene })
        .compactMap({ $0 })
        .first?.windows
        .filter({ $0.isKeyWindow }).first
    
    static func topViewController() -> UIViewController {
        if var topVC = keyWindow?.rootViewController {
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }
            return topVC
        }
        fatalError("Cannot find a rootViewController")
    }
    
    static func showVC(_ vc: UIViewController, withType type: MDShowVCActionType) {
        switch type {
        case .present:
            topViewController().present(vc, animated: true, completion: nil)
            break
            
        default:
            topViewController().navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
}
