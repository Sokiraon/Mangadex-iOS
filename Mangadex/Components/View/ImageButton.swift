//
//  ImageButton.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/25.
//

import Foundation
import UIKit

class ImageButton: UIButton {
    init(image: UIImage?) {
        super.init(frame: .zero)
        setImage(image, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
