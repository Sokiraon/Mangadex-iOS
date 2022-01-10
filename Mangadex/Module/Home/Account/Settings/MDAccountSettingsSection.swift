//
//  MDAccountSettingsModel.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/14.
//

import Foundation
import MaterialComponents

class MDAccountSettingsSection: MDCCard {
    
    convenience init(cells: [MDAccountSettingsCell]) {
        self.init()
        setupUI()
        for cell in cells {
            vStack.addArrangedSubview(cell)
        }
    }
    
    private let vStack = UIStackView()
    
    private func setupUI() {
        isInteractable = false
        setShadowElevation(.switch, for: .normal)
        backgroundColor = .white
        
        self +++ vStack
        vStack.axis = .vertical
        vStack.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    /// Add a cell to a settings section.
    static func <<< (section: MDAccountSettingsSection, cell: MDAccountSettingsCell) -> MDAccountSettingsSection {
        section.vStack.addArrangedSubview(cell)
        return section
    }
    
    /// Add a settings section to a view
    static func +++ (superview: UIView, section: MDAccountSettingsSection) {
        var i = section.vStack.arrangedSubviews.count - 1
        while i > 0 {
            let line = UIView(style: .line)
            section.vStack.insertArrangedSubview(line, at: i)
            line.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
            i -= 1
        }
        superview.addSubview(section)
    }
}
