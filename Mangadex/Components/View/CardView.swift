//
//  CardView.swift
//  Mangadex
//
//  Created by OpenAI Codex on 2026/5/9.
//

import UIKit

class CardView: UIView {
    private let backgroundLayer = CAShapeLayer()

    var fillColor: UIColor = .white {
        didSet {
            updateAppearance()
        }
    }

    var borderWidth: CGFloat = 0 {
        didSet {
            updateAppearance()
        }
    }

    var borderColor: UIColor = .clear {
        didSet {
            updateAppearance()
        }
    }

    var cornerRadius: CGFloat = 16 {
        didSet {
            updateAppearance()
            setNeedsLayout()
        }
    }

    var shadowCornerRadius: CGFloat = 24 {
        didSet {
            setNeedsLayout()
        }
    }

    var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    var shadowOpacity: Float = 0.06 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    var shadowOffset: CGSize = CGSize(width: 0, height: 4) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    var shadowRadius: CGFloat = 16 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        layer.insertSublayer(backgroundLayer, at: 0)
        updateAppearance()
    }

    private func updateAppearance() {
        backgroundLayer.fillColor = fillColor.cgColor
        backgroundLayer.lineWidth = borderWidth
        backgroundLayer.strokeColor = borderColor.cgColor
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        backgroundLayer.frame = bounds
        backgroundLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: shadowCornerRadius
        ).cgPath
    }
}
