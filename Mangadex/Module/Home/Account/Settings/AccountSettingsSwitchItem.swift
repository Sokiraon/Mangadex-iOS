//
//  AccountSettingsSwitchItem.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/17.
//

import Foundation
import UIKit
import SnapKit

class AccountSettingsSwitchItem: UIView {
    
    private let ivIcon = UIImageView().apply { iv in
        iv.tintColor = .darkGray808080
    }
    private let lblTitle = UILabel(
        fontSize: 15, fontWeight: .medium, color: .darkerGray565656
    )
    private lazy var vSwitch = UISwitch().apply { view in
        view.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }
    
    convenience init(icon: UIImage?, title: String, key: SettingsManager.Keys) {
        self.init()
        self.key = key
        vSwitch.setOn(UserDefaults.standard.bool(forKey: key.rawValue), animated: true)
        ivIcon.image = icon
        lblTitle.text = title
        setupUI()
    }
    
    private func setupUI() {
        addSubview(ivIcon)
        ivIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
            make.width.height.equalTo(24)
        }
        
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(ivIcon.snp.right).offset(10)
        }
        
        addSubview(vSwitch)
        vSwitch.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(15)
        }
    }
    
    private var key: SettingsManager.Keys!
    
    @objc private func onValueChanged() {
        UserDefaults.standard.set(vSwitch.isOn, forKey: key.rawValue)
        NotificationCenter.default.post(
            name: .MangadexDidChangeSettings,
            object: nil,
            userInfo: [
                "key": key!,
                "value": vSwitch.isOn,
            ]
        )
    }
}
