//
//  FollowedUpdatesCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/28.
//

import Foundation
import UIKit
import SnapKit
import SafariServices

class FollowedUpdatesChapterView: UIView {
    
    private var mangaModel: MangaModel
    private var chapterModel: ChapterModel
    
    let chapterView = ChapterView()
    
    init(mangaModel: MangaModel, chapterModel: ChapterModel) {
        self.mangaModel = mangaModel
        self.chapterModel = chapterModel
        
        super.init(frame: .zero)
        
        addSubview(chapterView)
        chapterView.setContent(with: chapterModel)
        chapterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    @objc private func didTapView() {
        if let externUrl = chapterModel.attributes.externalUrl,
           let url = URL(string: externUrl) {
            let vc = SFSafariViewController(url: url)
            MDRouter.topViewController?.present(vc, animated: true)
        } else {
            let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterModel.id)
            MDRouter.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            make.top.equalTo(divider.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    private var mangaModel: MangaModel!
    
    func setContent(
        mangaModel: MangaModel,
        chapters: [ChapterModel]
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
