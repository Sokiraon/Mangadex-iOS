//
//  MDLayout.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit

/**
 A helper class for layout-related variables and functions.
 */
@MainActor
enum MDLayout {

    static var keyWindow: UIWindow {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let activeScene = windowScenes
            .first { $0.activationState == .foregroundActive }

        if let window = windowScenes
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow }) {
            return window
        }

        if let window = activeScene?.windows.first {
            return window
        }

        guard let window = windowScenes.flatMap(\.windows).first else {
            preconditionFailure("Unable to resolve an app window for layout metrics.")
        }
        return window
    }

    static var safeAreaInsets: UIEdgeInsets {
        keyWindow.safeAreaInsets
    }

    static var safeInsetTop: CGFloat {
        safeAreaInsets.top
    }

    static var safeInsetBottom: CGFloat {
        safeAreaInsets.bottom
    }

    static var adjustedSafeInsetBottom: CGFloat {
        max(safeInsetBottom, 16)
    }

    static var isNotchScreen: Bool {
        safeInsetBottom > 0
    }

    static var scale: CGFloat {
        keyWindow.screen.scale
    }

    static var nativeScale: CGFloat {
        keyWindow.screen.nativeScale
    }

    static var native1px: CGFloat {
        1.0 / nativeScale
    }

    static var screenSize: CGSize {
        keyWindow.bounds.size
    }

    static var screenWidth: CGFloat {
        screenSize.width
    }

    static var screenHeight: CGFloat {
        screenSize.height
    }

    static var safeAreaSize: CGSize {
        CGSize(
            width: screenWidth - safeAreaInsets.left - safeAreaInsets.right,
            height: screenHeight - safeAreaInsets.top - safeAreaInsets.bottom
        )
    }

    static func vh(_ value: CGFloat) -> CGFloat {
        screenHeight * value / 100
    }
    
    static func vw(_ value: CGFloat) -> CGFloat {
        screenWidth * value / 100
    }
}

extension CGFloat {
    @MainActor
    public static var native1px: CGFloat {
        MDLayout.native1px
    }
}
