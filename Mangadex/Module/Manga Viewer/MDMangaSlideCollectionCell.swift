//
//  MDMangaSlideCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import UIKit
import Kingfisher

class MDMangaSlideCollectionCell: UICollectionViewCell {
    lazy var ivPage: UIImageView = {
        let iv = UIImageView()
        
        let pinchRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchView(recognizer:)))
        iv.addGestureRecognizer(pinchRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panView(recognizer:)))
        iv.addGestureRecognizer(panRecognizer)
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        ivPage.contentMode = .scaleAspectFit
        contentView.addSubview(ivPage)
        ivPage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
            make.height.equalTo(MDLayout.screenHeight)
        }
    }
    
    @objc func pinchView(recognizer: UIPinchGestureRecognizer) {
        let view = recognizer.view
        if (recognizer.state == .began || recognizer.state == .changed) {
            view?.transform = (view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
            recognizer.scale = 1
        }
    }
    
    @objc func panView(recognizer: UIPanGestureRecognizer) {
        let view = recognizer.view
        if (recognizer.state == .began || recognizer.state == .changed) {
            let translation = recognizer.translation(in: view)
            view?.center = CGPoint(x: (view?.center.x)! + translation.x, y: (view?.center.y)! + translation.y)
            recognizer.setTranslation(.zero, in: view?.superview)
        }
    }
}
