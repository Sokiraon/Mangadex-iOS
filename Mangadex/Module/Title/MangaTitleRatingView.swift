//
//  MangaTitleRatingView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/30.
//

import Foundation
import UIKit
import SnapKit
import SwiftEntryKit
import Cosmos

class MangaTitleRatingView: UIView {
    
    let dismissButton: UIButton = {
        let button = ImageButton(image: .init(named: "icon_dismiss"))
        button.tintColor = .darkGray808080
        button.addAction(UIAction { _ in
            SwiftEntryKit.dismiss()
        }, for: .touchUpInside)
        return button
    }()
    
    let titleLabel = UILabel(
        fontSize: 21, alignment: .center, scalable: true)
    
    var onSubmit: ((_ rating: Int) -> Void)!
    
    lazy var submitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "kOk".localized()
        config.buttonSize = .medium
        config.cornerStyle = .medium
        config.baseBackgroundColor = .themePrimary
        config.baseForegroundColor = .white
        config.contentInsets = .init(top: 9, leading: 16, bottom: 9, trailing: 16)
        let button = UIButton(configuration: config,
                              primaryAction: UIAction { _ in
            self.onSubmit(self.rating)
            SwiftEntryKit.dismiss()
        })
        return button
    }()
    
    let ratingView = CosmosView()
    let ratingLabel = UILabel(fontSize: 20, alignment: .center)
    
    var rating = 0 {
        didSet {
            ratingView.rating = Double(rating) / 2
            ratingLabel.text = "manga.rate.\(rating)".localized()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 8
        
        addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(24)
        }
        
        addSubview(titleLabel)
        titleLabel.text = "manga.detail.rate".localized()
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(dismissButton)
            make.right.equalTo(dismissButton.snp.left).offset(-8)
        }
        
        addSubview(ratingView)
        ratingView.settings.minTouchRating = 0
        ratingView.settings.fillMode = .half
        ratingView.settings.starSize = 30
        ratingView.settings.starMargin = 6
        ratingView.settings.filledColor = .themeDark
        ratingView.settings.emptyBorderColor = .themeDark
        ratingView.settings.filledBorderColor = .themeDark
        ratingView.settings.disablePanGestures = true
        ratingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        ratingView.didTouchCosmos = { rating in
            self.rating = Int(rating * 2)
//            self.ratingLabel.text = "manga.rate.\(rating)".localized()
        }
//        ratingView.didFinishTouchingCosmos = { rating in
//            self.rating = Int(rating * 2)
//        }
        
        addSubview(ratingLabel)
        ratingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ratingView.snp.bottom).offset(16)
        }
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(ratingLabel.snp.bottom).offset(24)
            make.left.right.bottom.equalToSuperview().inset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
