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
import SafariServices
import Kingfisher

private class BrowseMangaUpdateRowView: UIView {

    private let coverView = UIImageView()
    private let titleLabel = UILabel(fontSize: 18, fontWeight: .medium)
    private let chapterView = ChapterView()
    private var chapterModel: ChapterModel

    init(chapterModel: ChapterModel) {
        self.chapterModel = chapterModel
        super.init(frame: .zero)
        setupUI()
        setContent(with: chapterModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        isSkeletonable = true

        addSubview(coverView)
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 8
        coverView.contentMode = .scaleAspectFill
        coverView.isSkeletonable = true
        coverView.isUserInteractionEnabled = true
        coverView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(showMangaDetail)
        ))
        coverView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(96)
        }

        addSubview(titleLabel)
        titleLabel.isSkeletonable = true
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(showMangaDetail)
        ))
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.left.equalTo(coverView.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
        }

        addSubview(chapterView)
        chapterView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(openChapter)
        ))
        chapterView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
    }

    private func setContent(with model: ChapterModel) {
        chapterModel = model
        chapterView.setContent(with: model)
        showAnimatedSkeleton()
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

    @objc private func showMangaDetail() {
        if let mangaModel = chapterModel.mangaModel {
            let vc = MangaTitleViewController(mangaModel: mangaModel)
            MDRouter.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func openChapter() {
        if let externUrl = chapterModel.attributes.externalUrl,
           let url = URL(string: externUrl) {
            let vc = SFSafariViewController(url: url)
            MDRouter.topViewController?.present(vc, animated: true)
        } else if let mangaModel = chapterModel.mangaModel {
            let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterModel.id)
            MDRouter.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class BrowseMangaUpdatesCell: UICollectionViewCell {

    private let cardView = CardView()
    private let updatesStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        cardView.cornerRadius = 8
        cardView.shadowCornerRadius = 8
        cardView.shadowOpacity = 0.14
        cardView.shadowOffset = .zero
        cardView.shadowRadius = 6
        cardView.shadowPathInset = UIEdgeInsets(
            top: 3,
            left: 3,
            bottom: 3,
            right: 3
        )
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.addSubview(updatesStack)
        updatesStack.axis = .vertical
        updatesStack.spacing = 12
        updatesStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }

    func setContent(with models: [ChapterModel]) {
        clearUpdates()
        models.forEach { model in
            let rowView = BrowseMangaUpdateRowView(chapterModel: model)
            rowView.snp.makeConstraints { make in
                make.height.equalTo(96)
            }
            updatesStack.addArrangedSubview(rowView)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearUpdates()
    }

    private func clearUpdates() {
        updatesStack.arrangedSubviews.forEach { view in
            updatesStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
