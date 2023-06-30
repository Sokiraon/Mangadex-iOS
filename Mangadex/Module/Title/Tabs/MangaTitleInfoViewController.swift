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
    var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .lightGrayE5E5E5
        config.baseForegroundColor = .black2D2E2F
        config.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        button = UIButton(configuration: config)
        
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.greaterThanOrEqualTo(64)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class MangaTitleInfoViewController: BaseViewController {
    var mangaModel: MangaModel!
    
    let scrollView = ChildScrollView()
    let scrollContent = UIView()
    let descrTitle = BrowseMangaTitleSupplementaryView()
    let descrLabel = TTTAttributedLabel()
    var collectionView: UICollectionView!
    
    override func setupUI() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = .cssStyle(8, 0, MDLayout.adjustedSafeInsetBottom)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(42)
            make.left.right.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(scrollContent)
        scrollContent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        scrollContent.addSubview(descrTitle)
        descrTitle.label.text = "manga.detail.info.descr".localized()
        descrTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        
        scrollContent.addSubview(descrLabel)
        descrLabel.numberOfLines = 0
        descrLabel.snp.makeConstraints { make in
            make.top.equalTo(descrTitle.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
        }
        
        let parser = MarkdownParser()
        parser.link.color = .themeDark
        let descrStr = NSMutableAttributedString(
            attributedString: parser.parse(mangaModel.attributes.localizedDescription))
        let fontToUse = UIFont.systemFont(ofSize: 18)
        descrStr.addAttributes([.font: fontToUse],
                               range: .init(location: 0, length: descrStr.length))
        descrLabel.text = descrStr
        descrLabel.delegate = self
        descrLabel.contentMode = .top
        
        
        collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .bottom(MDLayout.adjustedSafeInsetBottom)
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        
        scrollContent.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descrLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(400)
        }
        
        setupDataSource()
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(80),
                                              heightDimension: .estimated(36))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(36))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    enum CollectionSection: Int {
        case authorArtist
        case tag
    }
    
    var dataSource: UICollectionViewDiffableDataSource<CollectionSection, String>!
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MangaInfoTagCell, String>
        { cell, indexPath, itemIdentifier in
            switch CollectionSection(rawValue: indexPath.section)! {
            case .authorArtist:
                var name = ""
                if let author = self.mangaModel.authors.first(where: { author in
                    author.id == itemIdentifier
                }) {
                    name = author.attributes.name
                    cell.button.configuration?.title = author.attributes.name
                }
                else if let artist = self.mangaModel.artists.first(where: { artist in
                    artist.id == itemIdentifier
                }) {
                    name = artist.attributes.name
                    cell.button.configuration?.title = artist.attributes.name
                }
                cell.button.addAction(UIAction { _ in
                    let vc = TaggedMangaViewController(
                        title: name, queryOptions: ["authorOrArtist": itemIdentifier])
                    self.navigationController?.pushViewController(vc, animated: true)
                }, for: .touchUpInside)
            case .tag:
                let tagModel = self.mangaModel.attributes.tags[indexPath.item]
                cell.button.configuration?.title = tagModel.localizedName()
                cell.button.addAction(UIAction { _ in
                    let vc = TaggedMangaViewController(
                        title: tagModel.localizedName(),
                        queryOptions: ["includedTags[]": tagModel.id!])
                    self.navigationController?.pushViewController(vc, animated: true)
                }, for: .touchUpInside)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<
            BrowseMangaTitleSupplementaryView>(elementKind: UICollectionView.elementKindSectionHeader)
        { supplementaryView, elementKind, indexPath in
            switch CollectionSection(rawValue: indexPath.section)! {
            case .authorArtist:
                supplementaryView.label.text = "manga.detail.info.author".localized()
            case .tag:
                supplementaryView.label.text = "manga.detail.info.tag".localized()
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, String>()
        snapshot.appendSections([.authorArtist, .tag])
        snapshot.appendItems(mangaModel.authors.map({ $0.id }),
                             toSection: .authorArtist)
        snapshot.appendItems(mangaModel.artists.map({ $0.id }),
                             toSection: .authorArtist)
        snapshot.appendItems(mangaModel.attributes.tags.map({ $0.id }),
                             toSection: .tag)
        dataSource.apply(snapshot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let collectionViewHeight = collectionView.contentSize.height
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(collectionViewHeight)
        }
        view.layoutIfNeeded()
    }
}

extension MangaTitleInfoViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true)
    }
}
