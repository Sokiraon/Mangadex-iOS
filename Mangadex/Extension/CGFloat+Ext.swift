//
//  CGFloat+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/19.
//

import Foundation

extension CGFloat {
    static func rectScreenOnlyValue(_ value: CGFloat) -> CGFloat {
        if MDLayout.isNotchScreen {
            return 0
        }
        return value
    }
}
