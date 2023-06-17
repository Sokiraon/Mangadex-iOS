//
//  AccountSettingsPushCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/24.
//

import Foundation
import UIKit

class AccountSettingsPushCell: AccountSettingsTappableCell {
    private let ivArrow = UIImageView(named: "icon_chevron_right", color: .darkerGray565656)
    
    var targetViewController: UIViewController?
    
    init() {
        super.init(frame: .zero)
        
        contentView.addSubview(ivArrow)
        ivArrow.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.right.equalToSuperview()
        }
    }
    
    override func didSelectCell() {
        if let vc = targetViewController {
            MDRouter.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
