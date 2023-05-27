//
//  AccountSettingsSection.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/14.
//

import Foundation
import UIKit

class AccountSettingsSection: UIView {
    
    convenience init(cells: UIView...) {
        self.init()
        
        for (index, cell) in cells.enumerated() {
            if index > 0 {
                let line = LineView()
                vStack.addArrangedSubview(line)
            }
            vStack.addArrangedSubview(cell)
        }
        
        setupUI()
    }
    
    private let vStack = UIStackView()
    
    private func setupUI() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
        
        vStack.axis = .vertical
        vStack.clipsToBounds = true
        vStack.layer.cornerRadius = 4
        vStack.backgroundColor = .white
        
        addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
