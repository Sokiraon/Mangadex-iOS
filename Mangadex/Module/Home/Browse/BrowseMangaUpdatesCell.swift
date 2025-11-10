//
//  BrowseMangaUpdatesCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation
import UIKit
import SnapKit
import SkeletonView

class BrowseMangaUpdatesCell: UICollectionViewCell {
    
    let coverView = UIImageView()
    let titleLabel = UILabel(fontSize: 18, fontWeight: .medium)
    let chapterView = ChapterView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.isSkeletonable = true
        
        contentView.addSubview(coverView)
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 4
        coverView.isSkeletonable = true
        coverView.isUserInteractionEnabled = true
        coverView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(showMangaDetail)))
        coverView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(96)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.isSkeletonable = true
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(showMangaDetail)))
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.left.equalTo(coverView.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
        }
        
        contentView.addSubview(chapterView)
        chapterView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
    }
    
    private var chapterModel: ChapterModel!
    
    func setContent(with model: ChapterModel) {
        self.chapterModel = model
        chapterView.setContent(with: model)
        contentView.showAnimatedSkeleton()
        if let mangaModel = model.mangaModel {
            updateContent(with: mangaModel)
        } else {
            Task { @MainActor in
                let mangaModel = try await Requests.Manga.get(id: model.mangaId ?? "")
                model.mangaModel = mangaModel
                self.updateContent(with: mangaModel)
            }
        }
    }
    
    private func updateContent(with model: MangaModel) {
        coverView.kf.setImage(with: model.coverURL) { _ in
            self.coverView.hideSkeleton()
        }
        titleLabel.hideSkeleton()
        titleLabel.text = model.attributes.localizedTitle
    }
    
    @objc func showMangaDetail() {
        if let mangaModel = chapterModel.mangaModel {
            let vc = MangaTitleViewController(mangaModel: mangaModel)
            MDRouter.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
