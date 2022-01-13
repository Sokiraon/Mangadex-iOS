//
//  MDAccountSettingsCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/14.
//

import Foundation
import SwiftEntryKit

enum MDAccountSettingsCellTextStyle {
    case oneLine, twoLine
}

enum MDAccountSettingsCellActionType {
    case selector, push
}

protocol MDAccountSettingsCellDelegate {
    func viewControllerToDisplay(forCell: MDAccountSettingsCell, withId: String) -> UIViewController?
    func viewToDisplay(forCell: MDAccountSettingsCell, withId: String) -> MDSettingsPopupView?
}

class MDAccountSettingsCell: UIView {
    
    private lazy var contentView = UIView()
    private lazy var ivIcon = UIImageView()
    private lazy var lblTitle = UILabel(fontSize: 15, fontWeight: .medium, color: .darkerGray565656)
    private lazy var lblSubtitle = UILabel(fontSize: 11, fontWeight: .medium, color: .darkGray808080)
    private lazy var ivNext = UIImageView(imageNamed: "icon_arrow_forward", color: .darkerGray565656)
    
    convenience init(textStyle: MDAccountSettingsCellTextStyle = .oneLine,
                     iconName: String,
                     title: String,
                     subtitle: String = "") {
        self.init()
        ivIcon.image = UIImage(named: iconName)
        ivIcon.tintColor = .darkGray808080
        
        lblTitle.text = title
        if (!subtitle.isEmpty) {
            lblSubtitle.text = subtitle
        }
        
        setupUI(textStyle: textStyle)
    }
    
    private func setupUI(textStyle: MDAccountSettingsCellTextStyle) {
        self +++ contentView
        contentView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(15)
        }
        
        contentView +++ [ivIcon, ivNext]
        ivIcon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.centerY.equalToSuperview()
        }
        ivNext.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.right.centerY.equalToSuperview()
        }
        
        switch textStyle {
        case .twoLine:
            contentView +++ [lblTitle, lblSubtitle]
            lblTitle.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalTo(ivIcon.snp.right).offset(10)
                make.right.equalTo(ivNext.snp.left).offset(-15)
            }
            lblSubtitle.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalTo(lblTitle.snp.bottom).offset(3)
                make.left.right.equalTo(lblTitle)
            }
            break
            
        default:
            contentView +++ lblTitle
            lblTitle.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(ivIcon.snp.right).offset(10)
                make.right.equalTo(ivNext.snp.left).offset(-15)
            }
            ivIcon.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
            break
        }
        
        addGestureRecognizer(tapGesture)
    }
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
    var delegate: MDAccountSettingsCellDelegate?
    
    // MARK: - Actions
    
    private var actionType: MDAccountSettingsCellActionType!
    private var id: String!
    
    func setActionType(_ actionType: MDAccountSettingsCellActionType, withId id: String) {
        self.actionType = actionType
        self.id = id
    }
    
    @objc private func didTapCell() {
        switch actionType {
        case .push:
            guard let vc = delegate?.viewControllerToDisplay(forCell: self, withId: self.id) else {
                fatalError("Cannot find a target viewcontroller to display")
            }
            MDRouter.showVC(vc, withType: .push)
            break
            
        default:
            guard let view = delegate?.viewToDisplay(forCell: self, withId: self.id) else {
                fatalError("Cannot find a view to display")
            }
            var attrs = EKAttributes.bottomFloat
            attrs.name = "Settings Popup"
            attrs.displayDuration = .infinity
            attrs.screenInteraction = .dismiss
            attrs.entryInteraction = .forward
            attrs.entryBackground = .color(color: .standardContent)
            attrs.screenBackground = .color(color: EKColor(UIColor(white: 0.5, alpha: 0.5)))
            attrs.entranceAnimation = .init(translate: .init(duration: 0.2), scale: nil, fade: nil)
            attrs.positionConstraints.size.width = .offset(value: 10)
            
            attrs.lifecycleEvents.willAppear = {
                view.viewWillAppear()
            }
            attrs.lifecycleEvents.didAppear = {
                view.viewDidAppear()
            }
            attrs.lifecycleEvents.willDisappear = {
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: SettingsPopupViewWillDisAppear),
                    object: nil
                )
            }
            
            SwiftEntryKit.display(entry: view, using: attrs)
            
            break
        }
    }
}
