//
//  CardView.swift
//  Mangadex
//
//  Created by OpenAI Codex on 2026/5/9.
//

import UIKit

class CardView: UIView {
    enum VisualStyle {
        case solid
        case glass
    }

    private let materialView = UIVisualEffectView(effect: nil)
    private let backgroundLayer = CAShapeLayer()
    private let highlightLayer = CAGradientLayer()

    var visualStyle: VisualStyle = .solid {
        didSet {
            updateAppearance()
        }
    }

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

    var shadowPathInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    func applyGlassStyle(cornerRadius: CGFloat = 24) {
        visualStyle = .glass
        fillColor = UIColor.white.withAlphaComponent(0.62)
        borderWidth = 1
        borderColor = UIColor.white.withAlphaComponent(0.82)
        shadowColor = .black
        shadowOpacity = 0.08
        shadowOffset = CGSize(width: 0, height: 8)
        shadowRadius = 22
        shadowPathInset = .all(2)
        self.cornerRadius = cornerRadius
        shadowCornerRadius = cornerRadius
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
        insertSubview(materialView, at: 0)
        materialView.isUserInteractionEnabled = false
        materialView.clipsToBounds = true

        highlightLayer.startPoint = CGPoint(x: 0.1, y: 0)
        highlightLayer.endPoint = CGPoint(x: 1, y: 1)
        highlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.72).cgColor,
            UIColor.white.withAlphaComponent(0.12).cgColor
        ]

        layer.insertSublayer(backgroundLayer, above: materialView.layer)
        layer.insertSublayer(highlightLayer, above: backgroundLayer)
        updateAppearance()
    }

    private func updateAppearance() {
        materialView.isHidden = visualStyle != .glass
        if visualStyle == .glass {
            materialView.effect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        } else {
            materialView.effect = nil
        }
        highlightLayer.isHidden = visualStyle != .glass
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
        materialView.frame = bounds
        materialView.layer.cornerRadius = cornerRadius
        materialView.layer.cornerCurve = .continuous

        backgroundLayer.frame = bounds
        backgroundLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath

        highlightLayer.frame = bounds
        highlightLayer.cornerRadius = cornerRadius
        highlightLayer.cornerCurve = .continuous
        highlightLayer.masksToBounds = true

        let shadowBounds = bounds.inset(by: shadowPathInset)
        layer.shadowPath = UIBezierPath(
            roundedRect: shadowBounds,
            cornerRadius: shadowCornerRadius
        ).cgPath
    }
}
