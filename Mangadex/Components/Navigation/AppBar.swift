//
//  AppBar.swift
//  Mangadex
//
//  Created by edz on 2021/6/8.
//

import Foundation
import UIKit
import SnapKit

class DynamicIntensityVisualEffectView: UIVisualEffectView {
    
    private var animator: UIViewPropertyAnimator!
    
    init(effect: UIVisualEffect?, intensity: CGFloat = 1) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
            self.effect = effect
        }
        animator.fractionComplete = intensity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class AppBar: UIView {
    
    enum Style {
        case filled
        case blur
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    let blurView = DynamicIntensityVisualEffectView(
        effect: UIBlurEffect(style: .extraLight), intensity: 0.6)
    
    lazy var btnBack: UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.image = .init(named: "icon_arrow_back")
        conf.baseForegroundColor = .white
        
        let button = UIButton(
            configuration: conf,
            primaryAction: UIAction { _ in
                MDRouter.navigationController?.popViewController(animated: true)
            }
        )
        return button
    }()
    
    lazy var lblTitle = UILabel(fontSize: 17, fontWeight: .medium, color: .white)
    var title: String? = nil {
        didSet {
            lblTitle.text = title
        }
    }
    
    func setupUI() {
        addSubview(btnBack)
        btnBack.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.snp.makeConstraints { make in
            make.left.equalTo(self.btnBack.snp.right).offset(24)
            make.centerY.equalTo(self.btnBack)
            make.centerX.equalTo(self)
        }
    }
    
    func addRightItem(_ view: UIView) {
        addSubview(view)
        view.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}
