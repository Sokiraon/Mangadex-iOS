//
//  LatestUpdateCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/13.
//

import Foundation
import UIKit

class LatestUpdateCollectionCell: UICollectionViewCell {
    
    let coverView = UIImageView()
    let titleLabel = UILabel(fontSize: 18, fontWeight: .medium)
    let flagView = UIImageView()
    let chapterLabel = UILabel(fontSize: 16, color: .primaryText)
    let groupIcon = UIImageView(named: "icon_group", color: .secondaryText)
    let groupLabel = UILabel(fontSize: 15, color: .secondaryText)
    let updateLabel = UILabel(fontSize: 15, color: .secondaryText)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(coverView)
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 4
        coverView.isUserInteractionEnabled = true
        coverView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(showMangaDetail)))
        coverView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(96)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(showMangaDetail)))
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.left.equalTo(coverView.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
        }
        
        contentView.addSubview(groupIcon)
        groupIcon.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(4)
            make.left.equalTo(coverView.snp.right).offset(8)
        }
        
        contentView.addSubview(groupLabel)
        groupLabel.snp.makeConstraints { make in
            make.centerY.equalTo(groupIcon)
            make.left.equalTo(groupIcon.snp.right).offset(8)
        }
        
        contentView.addSubview(updateLabel)
        updateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(groupIcon)
            make.right.equalToSuperview().inset(8)
        }
        
        contentView.addSubview(flagView)
        flagView.snp.makeConstraints { make in
            make.left.equalTo(groupIcon)
            make.width.equalTo(24)
            make.bottom.equalTo(groupIcon.snp.top).offset(-8)
        }
        
        contentView.addSubview(chapterLabel)
        chapterLabel.snp.makeConstraints { make in
            make.left.equalTo(flagView.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
            make.centerY.equalTo(flagView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var chapterModel: ChapterModel!
    
    func setContent(chapterModel: ChapterModel) {
        self.chapterModel = chapterModel
        flagView.image = chapterModel.attributes.languageFlag
        chapterLabel.text = chapterModel.attributes.fullChapterName
        groupLabel.text = chapterModel.groupName
        updateLabel.text = DateHelper.dateStringFromNow(
            isoDateString: chapterModel.attributes.updatedAt)
        if let mangaModel = chapterModel.mangaModel {
            coverView.kf.setImage(with: mangaModel.coverURL)
            titleLabel.text = mangaModel.attributes.localizedTitle
        } else {
            _ = Requests.Manga.get(id: chapterModel.mangaId ?? "")
                .done { mangaModel in
                    chapterModel.mangaModel = mangaModel
                    self.coverView.kf.setImage(with: mangaModel.coverURL)
                    self.titleLabel.text = mangaModel.attributes.localizedTitle
                }
        }
    }
    
    @objc func showMangaDetail() {
        if let mangaModel = chapterModel.mangaModel {
            let vc = MangaDetailViewController(mangaModel: mangaModel)
            MDRouter.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
