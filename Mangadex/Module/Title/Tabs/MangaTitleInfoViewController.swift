//
//  MangaTitleInfoViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/27.
//

import Foundation
import UIKit
import SnapKit
import TTTAttributedLabel
import SafariServices
import MarkdownKit

class MangaInfoTagCell: UICollectionViewCell {
    private var onTap: (() -> Void)?
    private lazy var button = UIButton(
        configuration: makeButtonConfiguration(),
        primaryAction: UIAction { [weak self] _ in
            self?.onTap?()
        }
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func makeButtonConfiguration() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .lightGrayE5E5E5
        config.baseForegroundColor = .black2D2E2F
        config.contentInsets = .cssStyle(8, 16)
        return config
    }

    private func setupUI() {
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTap = nil
        button.configuration?.title = nil
    }

    func setContent(title: String?, onTap: @escaping () -> Void) {
        button.configuration?.title = title
        self.onTap = onTap
    }
}

private class MangaInfoDescriptionCell: UICollectionViewCell {
    private let descrLabel = TTTAttributedLabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(descrLabel)
        descrLabel.numberOfLines = 0
        descrLabel.contentMode = .top
        descrLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        descrLabel.preferredMaxLayoutWidth = contentView.bounds.width
    }

    func setContent(
        attributedText: NSAttributedString,
        delegate: TTTAttributedLabelDelegate?
    ) {
        descrLabel.text = attributedText
        descrLabel.delegate = delegate
    }
}

private class MangaInfoSectionBackgroundView: UICollectionReusableView {
    private let cardView = CardView().apply { view in
        view.applyGlassStyle(cornerRadius: 24)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class MangaTitleInfoViewController: BaseViewController {
    private static let sectionBackgroundElementKind = "MangaInfoSectionBackground"

    var mangaModel: MangaModel!

    lazy var collectionView = ChildCollectionView(
        frame: .zero,
        collectionViewLayout: createCompositionalLayout()
    )

    private lazy var descriptionAttributedText: NSAttributedString = {
        let parser = MarkdownParser()
        parser.link.color = .themeDark
        let descrStr = NSMutableAttributedString(
            attributedString: parser.parse(mangaModel.attributes.localizedDescription))
        let fontToUse = UIFont.systemFont(ofSize: 18)
        descrStr.addAttributes([.font: fontToUse],
                               range: .init(location: 0, length: descrStr.length))
        return descrStr
    }()

    override func setupUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .cssStyle(8, 0, MDLayout.adjustedSafeInsetBottom)
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false
        collectionView.showsVerticalScrollIndicator = false

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(64)
            make.left.right.bottom.equalToSuperview()
        }
        
        setupDataSource()
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let sectionKind = CollectionSection(rawValue: sectionIndex) else {
                return nil
            }
            switch sectionKind {
            case .description:
                return self.makeDescriptionSection()
            case .authorArtist, .tag:
                return self.makeTagSection()
            }
        }
        layout.register(
            MangaInfoSectionBackgroundView.self,
            forDecorationViewOfKind: Self.sectionBackgroundElementKind
        )
        return layout
    }

    private func makeDescriptionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(160)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = makeCardSection(group: group)
        section.interGroupSpacing = 0
        return section
    }

    private func makeTagSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .estimated(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(36)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(10)

        let section = makeCardSection(group: group)
        section.interGroupSpacing = 12
        return section
    }

    private func makeCardSection(
        group: NSCollectionLayoutGroup
    ) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(
            top: 0,
            leading: 28,
            bottom: 20,
            trailing: 28
        )

        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(48)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]

        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: Self.sectionBackgroundElementKind
        )
        backgroundItem.contentInsets = .init(
            top: 0,
            leading: 16,
            bottom: 8,
            trailing: 16
        )
        section.decorationItems = [backgroundItem]
        return section
    }
    
    enum CollectionSection: Int {
        case description
        case authorArtist
        case tag
    }

    enum InfoItem: Hashable {
        case description
        case author(String)
        case artist(String)
        case tag(String)
    }
    
    var dataSource: UICollectionViewDiffableDataSource<CollectionSection, InfoItem>!
    
    func setupDataSource() {
        let descriptionCellRegistration = UICollectionView.CellRegistration<
            MangaInfoDescriptionCell, InfoItem
        > { [weak self] cell, _, _ in
            guard let self else { return }
            cell.setContent(
                attributedText: self.descriptionAttributedText,
                delegate: self
            )
        }

        let tagCellRegistration = UICollectionView.CellRegistration<MangaInfoTagCell, InfoItem>
        { [weak self] cell, _, itemIdentifier in
            guard let self else { return }
            switch itemIdentifier {
            case .description:
                break
            case .author(let id):
                if let author = self.mangaModel.authors.first(where: { author in
                    author.id == id
                }) {
                    cell.setContent(title: author.attributes.name) { [weak self] in
                        let vc = TaggedMangaViewController(
                            title: author.attributes.name,
                            queryOptions: ["authorOrArtist": id]
                        )
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .artist(let id):
                if let artist = self.mangaModel.artists.first(where: { artist in
                    artist.id == id
                }) {
                    cell.setContent(title: artist.attributes.name) { [weak self] in
                        let vc = TaggedMangaViewController(
                            title: artist.attributes.name,
                            queryOptions: ["authorOrArtist": id]
                        )
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .tag(let id):
                guard let tagModel = self.mangaModel.attributes.tags.first(where: { tag in
                    tag.id == id
                }) else {
                    return
                }
                cell.setContent(title: tagModel.localizedName()) { [weak self] in
                    let vc = TaggedMangaViewController(
                        title: tagModel.localizedName(),
                        queryOptions: ["includedTags[]": tagModel.id!])
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .description:
                collectionView.dequeueConfiguredReusableCell(
                    using: descriptionCellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            case .author, .artist, .tag:
                collectionView.dequeueConfiguredReusableCell(
                    using: tagCellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<
            MangaTitleInfoSupplementaryView
        >(elementKind: UICollectionView.elementKindSectionHeader)
        { supplementaryView, _, indexPath in
            switch CollectionSection(rawValue: indexPath.section)! {
            case .description:
                supplementaryView
                    .setContent(
                        image: UIImage(systemName: "info.circle.fill"),
                        text: String(localized: "manga.detail.info.descr")
                    )
            case .authorArtist:
                supplementaryView
                    .setContent(
                        image: UIImage(systemName: "person.circle.fill"),
                        text: String(localized: "manga.detail.info.author")
                    )
            case .tag:
                supplementaryView
                    .setContent(
                        image: UIImage(systemName: "tag.circle.fill"),
                        text: String(localized: "manga.detail.info.tag")
                    )
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, InfoItem>()
        snapshot.appendSections([.description, .authorArtist, .tag])
        snapshot.appendItems([.description], toSection: .description)
        snapshot.appendItems(
            mangaModel.authors.map { .author($0.id) },
            toSection: .authorArtist
        )
        snapshot.appendItems(
            mangaModel.artists.map { .artist($0.id) },
            toSection: .authorArtist
        )
        snapshot.appendItems(
            mangaModel.attributes.tags.map { .tag($0.id) },
            toSection: .tag
        )
        dataSource.apply(snapshot)
    }
}

extension MangaTitleInfoViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true)
    }
}
