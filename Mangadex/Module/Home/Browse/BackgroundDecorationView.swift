//
//  BackgroundDecorationView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation
import UIKit

class BackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.cornerRadius = 8
        backgroundColor = .lightestGrayF5F5F5
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
