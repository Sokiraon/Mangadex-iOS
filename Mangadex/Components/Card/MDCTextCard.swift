//
// Created by John Rion on 2021/7/17.
//

import Foundation
import SnapKit
import UIKit

class MDCTextCard : MDCCustomCard {
    private lazy var lblMessage = UILabel(color: .darkerGray565656, numberOfLines: 0)
    
    convenience init(title: String, content: String) {
        self.init(title: title)
        update(title: title, content: content)
        
        contentView.addSubview(lblMessage)
        lblMessage.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
        }
    }
    
    convenience init(title: String, subtitle: String, message: String) {
        self.init()
    }
    
    func update(
        title: String? = nil,
        subtitle: String? = nil,
        content: String? = nil,
        attributedContent: NSAttributedString? = nil
    ) {
        if (title != nil) {
            lblTitle.text = title
        }
        if (subtitle != nil) {
            lblSubtitle.text = subtitle
        }
        if (content != nil) {
            lblMessage.text = content
        }
        if (attributedContent != nil) {
            let str = NSMutableAttributedString(attributedString: attributedContent!)
            let attrs = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.black2D2E2F
            ]
            str.setAttributes(attrs, range: NSRange(location: 0, length: str.length))
            lblMessage.attributedText = str
        }
    }
}
