//
//  MDMangaChapterCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit

class MDMangaChapterCollectionCell: UICollectionViewCell {
    var volumeName: String?
    var chapterName: String!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        contentView.backgroundColor = MDColor.get(.lightGrayE5E5E5)
        contentView.layer.cornerRadius = 5

        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(15)
        }
    }

    func setWithVolume(_ volume: String?, andChapter chapter: String, withProgress progress: String?) {
        volumeName = volume
        chapterName = chapter
        lblTitle.text = chapter
        if (chapter == progress) {
            contentView.backgroundColor = MDColor.get(.lightOrange)
        } else {
            contentView.backgroundColor = MDColor.get(.lightGrayE5E5E5)
        }
    }

    lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
}
