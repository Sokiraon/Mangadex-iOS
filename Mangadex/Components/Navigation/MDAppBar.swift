//
//  MDAppBar.swift
//  Mangadex
//
//  Created by edz on 2021/6/8.
//

import Foundation
import UIKit

class MDAppBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
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
            make.left.equalTo(self.btnBack.snp.right).offset(15)
            make.centerY.equalTo(self.btnBack)
            make.centerX.equalTo(self)
        }
    }
}
