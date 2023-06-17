//
//  AccountSettingsSwitchCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/17.
//

import Foundation
import UIKit
import SnapKit

class AccountSettingsSwitchCell: AccountSettingsCell {
    
    private lazy var vSwitch = UISwitch().apply { view in
        view.theme_onTintColor = UIColor.themePrimaryPicker
        view.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }
    
    init(key: SettingsManager.Keys) {
        super.init(frame: .zero)
        self.key = key
        
        contentView.addSubview(vSwitch)
        vSwitch.setOn(UserDefaults.standard.bool(forKey: key.rawValue), animated: true)
        vSwitch.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
