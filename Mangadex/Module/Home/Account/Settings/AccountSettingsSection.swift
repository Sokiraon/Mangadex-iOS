//
//  AccountSettingsSection.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/14.
//

import UIKit
import SnapKit

class AccountSettingsSection: CardView {
    private let vStack = UIStackView()
    
    convenience init(cells: UIView...) {
        self.init(frame: .zero)
        
        for (index, cell) in cells.enumerated() {
            if index > 0 {
                let line = LineView()
                vStack.addArrangedSubview(line)
            }
            vStack.addArrangedSubview(cell)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        vStack.axis = .vertical
        vStack.clipsToBounds = true
        vStack.layer.cornerRadius = cornerRadius
        vStack.backgroundColor = .clear
        guard vStack.superview == nil else { return }

        addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        vStack.layer.cornerRadius = cornerRadius
    }
}
