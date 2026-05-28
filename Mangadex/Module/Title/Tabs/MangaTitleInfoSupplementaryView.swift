//
//  MangaTitleInfoSupplementaryView.swift
//  Mangadex
//
//  Created by John Rion on 2026/05/28.
//

import Foundation
import UIKit
import SnapKit

class MangaTitleInfoSupplementaryView: UICollectionReusableView {
    private let icon = UIImageView()
    private let label = UILabel(fontSize: 20, fontWeight: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(icon)
        icon.tintColor = UIColor.themeDark
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.size.equalTo(32)
        }

        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(icon)
        }
    }

    func setContent(image: UIImage?, text: String?) {
        icon.image = image
        label.text = text
    }
}
