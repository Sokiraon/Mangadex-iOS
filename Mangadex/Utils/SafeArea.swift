//
//  ContentInsets.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/05.
//

import Foundation

extension CGFloat {
    static func rectScreenOnly(_ value: Self) -> Self {
        MDLayout.isNotchScreen ? 0 : value
    }
}
