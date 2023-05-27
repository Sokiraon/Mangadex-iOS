//
//  LineView.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/25.
//

import Foundation
import UIKit

class LineView: UIView {
    enum Axis {
        case horizontal, vertical
    }
    
    init(axis: Axis = .horizontal) {
        super.init(frame: .zero)
        
        backgroundColor = .grayDFDFDF
        if axis == .horizontal {
            snp.makeConstraints { make in
                make.height.equalTo(MDLayout.native1px * 2)
            }
        } else {
            snp.makeConstraints { make in
                make.width.equalTo(MDLayout.native1px * 2)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
