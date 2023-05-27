//
//  AccountSettingsColorPickerView.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import SwiftTheme

class AccountSettingsColorPickerItem: UIView {
    private lazy var colorSample = UIView()
    private lazy var colorLabel = UILabel(fontSize: 20)
    private lazy var contentStack = UIStackView(arrangedSubviews: [colorSample, colorLabel]).apply { stack in
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalSpacing
    }
    
    init(color: UIColor, colorString: String) {
        super.init(frame: .zero)
        
        addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        colorLabel.text = colorString
        
        colorSample.backgroundColor = color
        colorSample.layer.cornerRadius = 10
        colorSample.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AccountSettingsColorPickerView: AccountSettingsPickerView {
    
    override var title: String {
        "kSettingsThemeColor".localized()
    }
    
    private let dataModel: [UIColor: String] = [
        .cerulean400: "Cerulean".localized(),
        .teal300: "Teal".localized(),
        .coral400: "Coral".localized(),
    ]
    
    override func setupUI() {
        super.setupUI()
        pickerView.selectRow(ThemeManager.currentThemeIndex, inComponent: 0, animated: false)
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataModel.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let key = Array(dataModel.keys)[row]
        return AccountSettingsColorPickerItem(color: key, colorString: dataModel[key]!)
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SettingsManager.themeColorIndex = row
        super.pickerView(pickerView, didSelectRow: row, inComponent: component)
    }
}
