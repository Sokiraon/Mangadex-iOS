//
//  MDSettingsPopopView.swift
//  Mangadex
//
//  Created by John Rion on 12/13/21.
//

import Foundation
import UIKit
import SwiftEntryKit
import SnapKit

class MDSettingsPopopView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private lazy var btnDismiss: UIButton = {
        let btn = UIButton(imgNormal: UIImage(named: "icon_dismiss"))
        btn.tintColor = MDColor.get(.black323232)
        btn.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        return btn
    }()
    
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        addSubview(btnDismiss)
        btnDismiss.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.bottom.lessThanOrEqualToSuperview().inset(300)
            make.width.height.equalTo(24)
        }
        
        layoutIfNeeded()
    }
    
    @objc func didTapDismiss() {
        SwiftEntryKit.dismiss()
    }
}
