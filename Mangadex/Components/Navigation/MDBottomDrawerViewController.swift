//
//  MDBottomDrawerViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/8/15.
//

import Foundation

enum MDBottomDrawerStyle {
    /** Isolated, with all corners radius to 10px */
    case float
    /** Bottom sheet, with top corners radius to 10px */
    case sheet
}

class MDBottomDrawerViewController: MDViewController {
    
    private var style: MDBottomDrawerStyle!
    convenience init(style: MDBottomDrawerStyle) {
        self.init()
        self.style = style
    }
    
    private var contentView: MDRoundedView!
    
    override func setupUI() {
        switch style {
        case .float:
            contentView = MDRoundedView(roundedCorners: .allCorners)
            break
            
        default:
            contentView = MDRoundedView(roundedCorners: [.topLeft, .topRight])
            break
        }
        
        contentView.backgroundColor = .white
        view +++ contentView
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.bottom)
        }
    }
}
