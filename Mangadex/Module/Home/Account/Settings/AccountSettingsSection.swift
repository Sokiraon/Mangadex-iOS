//
//  AccountSettingsSection.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/14.
//

import Foundation
import UIKit

class AccountSettingsSection: UIView {
    
    convenience init(cells: [UIView]) {
        self.init()
        vStack = UIStackView(arrangedSubviews: cells)
        var i = cells.count - 1
        while i > 0 {
            let line = UIView(style: .lineHorizontal)
            vStack.insertArrangedSubview(line, at: i)
            i -= 1
        }
        setupUI()
    }
    
    private var vStack: UIStackView!
    
    private func setupUI() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
        layer.cornerRadius = 4
        
        backgroundColor = .white
        
        addSubview(vStack)
        vStack.axis = .vertical
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
