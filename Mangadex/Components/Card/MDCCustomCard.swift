//
// Created by John Rion on 2021/7/17.
//

import Foundation
import MaterialComponents
import SnapKit

class MDCCustomCard : MDCCard {
    lazy var lblTitle = UILabel(fontSize: 24, fontWeight: .bold, scalable: true)
    lazy var lblSubtitle = UILabel(color: .darkGray808080, numberOfLines: 0)
    lazy var contentView = UIView()
    
    func updateContent(title: String? = nil, subtitle: String? = nil) {
        if (title != nil) {
            lblTitle.text = title
        }
        if (subtitle != nil) {
            lblSubtitle.text = subtitle
        }
    }
    
    convenience init(title: String) {
        self.init()
        
        isInteractable = false
        updateContent(title: title)
        
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(20)
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(lblTitle.snp.bottom).offset(20)
            make.bottom.equalTo(-20)
        }
    }
    
    convenience init(title: String, subtitle: String) {
        self.init()
        
        isInteractable = false
        updateContent(title: title, subtitle: subtitle)
        
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(20)
        }
        
        addSubview(lblSubtitle)
        lblSubtitle.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(lblTitle.snp.bottom).offset(15)
        }
    
        addSubview(contentView)
        contentView.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(lblSubtitle.snp.bottom).offset(20)
            make.bottom.equalTo(-20)
        }
    }
    
    func applyBorder(color: Colors = .lightGrayE5E5E5) {
        setBorderColor(MDColor.get(color), for: .normal)
        setBorderWidth(1, for: .normal)
    }
}
