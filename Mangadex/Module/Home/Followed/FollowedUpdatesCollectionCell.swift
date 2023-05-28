//
//  FollowedUpdatesCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/28.
//

import Foundation
import UIKit
import SnapKit

class FollowedUpdatesChapterView: UIView {
    
    private var mangaModel: MangaItemDataModel
    private var chapterModel: MDMangaChapterModel
    
    init(
        mangaModel: MangaItemDataModel,
        chapterModel: MDMangaChapterModel
    ) {
        self.mangaModel = mangaModel
        self.chapterModel = chapterModel
        
        super.init(frame: .zero)
        setupUI()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let ivFlag = UIImageView()
    private let lblTitle = UILabel(
        fontSize: 16,
        fontWeight: .medium,
        scalable: false
    )
    
    private let ivGroup = UIImageView(named: "icon_group", color: .secondaryText)
    private let lblGroup = UILabel(fontSize: 15, color: .secondaryText)
    
    private let lblUpdate = UILabel(fontSize: 15, color: .secondaryText)
    
    private func setupUI() {
        addSubview(ivFlag)
        ivFlag.image = chapterModel.attributes.languageFlag
        ivFlag.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(24)
        }
        
        addSubview(lblTitle)
        lblTitle.text = chapterModel.attributes.fullChapterName
        lblTitle.snp.makeConstraints { make in
            make.centerY.equalTo(ivFlag)
            make.top.equalToSuperview().inset(6)
            make.left.equalTo(ivFlag.snp.right).offset(6)
            make.right.equalToSuperview()
        }
        
        addSubview(lblUpdate)
        lblUpdate.text = MDFormatter.dateStringFromNow(
            isoDateString: chapterModel.attributes.updatedAt)
        lblUpdate.snp.makeConstraints { make in
            make.top.equalTo(ivFlag.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().inset(6)
        }
        
        if let group = chapterModel.scanlationGroup {
            addSubview(lblGroup)
            lblGroup.text = group.attributes.name
            lblGroup.snp.makeConstraints { make in
                make.centerY.equalTo(lblUpdate)
                make.right.equalToSuperview()
            }
            
            addSubview(ivGroup)
            ivGroup.snp.makeConstraints { make in
                make.centerY.equalTo(lblUpdate)
                make.width.height.equalTo(18)
                make.right.equalTo(lblGroup.snp.left).offset(-4)
                make.left.greaterThanOrEqualTo(lblUpdate.snp.right).offset(32)
            }
        }
    }
    
    @objc private func didTapView() {
        let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterModel.id)
        MDRouter.navigationController?.pushViewController(vc, animated: true)
    }
}

class FollowedUpdatesCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let lblTitle = UILabel(
        fontSize: 17,
        fontWeight: .medium,
        scalable: false
    )
    private let divider = LineView()
    private let chapterStack = UIStackView()
    
    private func setupUI() {
        layer.cornerRadius = 4
        backgroundColor = .lightestGrayF5F5F5
        
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.snp.makeConstraints { make in
            make.width.equalTo(MDLayout.screenWidth - 20)
        }
        
        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
        }
        
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.left.right.equalTo(lblTitle)
            make.top.equalTo(lblTitle.snp.bottom).offset(4)
        }
        
        contentView.addSubview(chapterStack)
        chapterStack.axis = .vertical
        chapterStack.snp.makeConstraints { make in
            make.left.right.equalTo(lblTitle)
            make.top.equalTo(divider.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private var mangaModel: MangaItemDataModel!
    
    func setContent(
        mangaModel: MangaItemDataModel,
        chapters: [MDMangaChapterModel]
    ) {
        self.mangaModel = mangaModel
        lblTitle.text = mangaModel.attributes.localizedTitle
        for (index, chapterModel) in chapters.enumerated() {
            if index > 0 {
                chapterStack.addArrangedSubview(LineView())
            }
            let chapterView = FollowedUpdatesChapterView(
                mangaModel: mangaModel, chapterModel: chapterModel)
            chapterStack.addArrangedSubview(chapterView)
        }
    }
    
    override func prepareForReuse() {
        chapterStack.arrangedSubviews.forEach { view in
            chapterStack.removeArrangedSubview(view)
            NSLayoutConstraint.deactivate(view.constraints)
            view.removeFromSuperview()
        }
        super.prepareForReuse()
    }
}
