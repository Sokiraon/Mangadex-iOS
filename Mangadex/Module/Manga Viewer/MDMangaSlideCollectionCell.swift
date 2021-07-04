//
//  MDMangaSlideCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import UIKit
import Kingfisher

class MDMangaSlideCollectionCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    lazy var ivPage: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true

        let doubleTapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapView(recognizer:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        iv.addGestureRecognizer(doubleTapRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchView(recognizer:)))
        pinchRecognizer.delegate = self
        iv.addGestureRecognizer(pinchRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panView(recognizer:)))
        panRecognizer.delegate = self
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

    @objc func doubleTapView(recognizer: UITapGestureRecognizer) {
        let view = recognizer.view
        if ((view?.frame.width)! > MDLayout.screenWidth) {
            UIView.animate(withDuration: 0.3) {
                view?.transform = .identity
                view?.frame.origin = .zero
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                view?.transform = (view?.transform.scaledBy(x: 2, y: 2))!
            }
        }
    }
    
    @objc func pinchView(recognizer: UIPinchGestureRecognizer) {
        let view = recognizer.view
        if (recognizer.state == .began || recognizer.state == .changed) {
            view?.transform = (view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
            recognizer.scale = 1
        } else if (recognizer.state == .ended) {
            if (ivPage.frame.width <= MDLayout.screenWidth) {
                UIView.animate(withDuration: 0.3) {
                    view?.transform = .identity
                }
            }
        }
    }

    var scrollBack: (() -> Void)!
    var scrollForward: (() -> Void)!

    @objc func panView(recognizer: UIPanGestureRecognizer) {
        let view = recognizer.view
        if (recognizer.state == .began || recognizer.state == .changed) {
            let translation = recognizer.translation(in: view)
            view?.center = CGPoint(x: (view?.center.x)! + translation.x, y: (view?.center.y)! + translation.y)
            recognizer.setTranslation(.zero, in: view?.superview)
        } else if (recognizer.state == .ended) {
            guard (ivPage.frame.width > MDLayout.screenWidth) else {
                if (ivPage.frame.origin.x > 0) {
                    scrollBack()
                } else {
                    scrollForward()
                }
                return
            }
            if (ivPage.frame.origin.x > 0) {
                UIView.animate(withDuration: 0.3) {
                    self.ivPage.frame.origin.x = 0
                }
            } else if (ivPage.frame.origin.y > 0) {
                UIView.animate(withDuration: 0.3) {
                    self.ivPage.frame.origin.y = 0
                }
            }
        }
    }
}
