//
// Created by John Rion on 2021/7/17.
//

import Foundation
import MaterialComponents
import SnapKit

class MDCTextCard : MDCCustomCard {
    private lazy var lblMessage = UILabel(color: .darkerGray565656, numberOfLines: 0)
    
    convenience init(title: String, message: String) {
        self.init(title: title)
        updateContent(title: title, message: message)
        
        contentView.addSubview(lblMessage)
        lblMessage.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
        }
    }
    
    convenience init(title: String, subtitle: String, message: String) {
        self.init()
    }
    
    func updateContent(title: String? = nil, subtitle: String? = nil, message: String? = nil) {
        if (title != nil) {
            lblTitle.text = title
        }
        if (subtitle != nil) {
            lblSubtitle.text = subtitle
        }
        if (message != nil) {
            lblMessage.text = message
        }
    }
}
