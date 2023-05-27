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
import SwiftTheme

class AccountSettingsPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private lazy var btnDismiss: UIButton = {
        let btn = ImageButton(image: .init(named: "icon_dismiss"))
        btn.tintColor = .darkGray808080
        btn.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        return btn
    }()
    
    internal lazy var lblTitle = UILabel(
        fontSize: 21,
        color: .black2D2E2F,
        scalable: true
    )
    
    internal lazy var pickerView = UIPickerView().apply { picker in
        picker.delegate = self
        picker.dataSource = self
    }
    
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        
        addSubview(btnDismiss)
        btnDismiss.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.width.height.equalTo(24)
        }
        
        addSubview(lblTitle)
        lblTitle.text = title
        lblTitle.textAlignment = .center
        lblTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(btnDismiss)
            make.right.equalTo(btnDismiss.snp.left).offset(-15)
        }
        
        addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.top.equalTo(btnDismiss.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(24 + 10)
        }
    }
    
    @objc func didTapDismiss() {
        SwiftEntryKit.dismiss()
    }
    
    var title: String {
        ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        32
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NotificationCenter.default.post(name: .MangadexDidChangeSettings, object: nil)
    }
}
