//
//  BrowseMangaViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import PromiseKit
import SnapKit
import SafariServices

extension UICollectionView {
    public static let elementKindBackground = "background-element-kind"
}

class BrowseMangaViewController: BaseViewController {
    
    enum SectionLayoutKind: Int {
        case popular
        case updates
        case seasonal
        case added
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, String>!
    
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let sectionKind = SectionLayoutKind(rawValue: sectionIndex) else {
                return nil
            }
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .absolute(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            switch sectionKind {
            case .popular:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(MDLayout.screenWidth - 24),
                                                       heightDimension: .absolute(256))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            case .updates:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .absolute(96))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(MDLayout.screenWidth - 24),
                                                       heightDimension: .absolute(328))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             repeatingSubitem: item,
                                                             count: 3)
                group.interItemSpacing = .fixed(12)
                group.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [sectionHeader]
                
                let sectionBackground = NSCollectionLayoutDecorationItem.background(
                    elementKind: UICollectionView.elementKindBackground)
                sectionBackground.contentInsets = .init(top: 44 + 8, leading: 12, bottom: 8, trailing: 12)
                section.decorationItems = [sectionBackground]
                return section
            case .seasonal, .added:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(96),
                                                       heightDimension: .estimated(190))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             repeatingSubitem: item,
                                                             count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            }
        }
        layout.register(BackgroundDecorationView.self,
                        forDecorationViewOfKind: UICollectionView.elementKindBackground)
        
        return layout
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeCompositionalLayout()
    ).apply { view in
        view.backgroundColor = .systemBackground
        view.delegate = self
    }
    
    private lazy var collectionHeaderView = BrowseMangaHeaderView() { view in
        view.setRefreshing(true)
        self.fetchData()
    }
    
    override func setupUI() {
        view.addSubview(collectionView)
        collectionView.contentInset = .init(top: 56, left: 0, bottom: 12, right: 0)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
            make.left.right.bottom.equalToSuperview()
        }
        
        collectionView.addSubview(collectionHeaderView)
        collectionHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-56)
            make.left.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
            make.height.equalTo(56)
        }
    }
    
    override func didSetupUI() {
        configureDataSource()
        fetchData()
    }
    
    private var popularTitles = [MangaModel]()
    private var seasonalTitles = [MangaModel]()
    private var recentTitles = [MangaModel]()
    private var latestChapters = [ChapterModel]()
    
    private func configureDataSource() {
        let popularCellRegistration = UICollectionView.CellRegistration<BrowseMangaPopularCell, String>
        { cell, indexPath, identifier in
            cell.setContent(mangaModel: self.popularTitles[indexPath.item])
        }
        
        let updatesCellRegistration = UICollectionView.CellRegistration<BrowseMangaUpdatesCell, String>
        { cell, indexPath, identifier in
            cell.setContent(with: self.latestChapters[indexPath.item])
        }
        
        let seasonalCellRegistration = UICollectionView.CellRegistration<BrowseMangaMinimalCell, String>
        { cell, indexPath, identifier in
            cell.setContent(mangaModel: self.seasonalTitles[indexPath.item])
        }
        
        let recentCellRegistration = UICollectionView.CellRegistration<BrowseMangaMinimalCell, String>
        { cell, indexPath, identifier in
            cell.setContent(mangaModel: self.recentTitles[indexPath.item])
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<BrowseMangaTitleSupplementaryView>(
            elementKind: UICollectionView.elementKindSectionHeader)
        { supplementaryView, elementKind, indexPath in
            switch SectionLayoutKind(rawValue: indexPath.section)! {
            case .popular:
                supplementaryView.label.text = "browse.section.popular".localized()
                break
            case .updates:
                supplementaryView.label.text = "browse.section.updates".localized()
                break
            case .seasonal:
                supplementaryView.label.text = "browse.section.seasonal".localized()
                break
            case .added:
                supplementaryView.label.text = "browse.section.recent".localized()
                break
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            switch SectionLayoutKind(rawValue: indexPath.section)! {
            case .popular:
                return collectionView.dequeueConfiguredReusableCell(
                    using: popularCellRegistration, for: indexPath, item: itemIdentifier)
            case .updates:
                return collectionView.dequeueConfiguredReusableCell(
                    using: updatesCellRegistration, for: indexPath, item: itemIdentifier)
            case .seasonal:
                return collectionView.dequeueConfiguredReusableCell(
                    using: seasonalCellRegistration, for: indexPath, item: itemIdentifier)
            case .added:
                return collectionView.dequeueConfiguredReusableCell(
                    using: recentCellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath)
        }
    }
    
    private func fetchData() {
        var oneMonthBefore = DateHelper.dateStringFromNow(month: -1)
        // Delete the 'Z' character in the end of string
        oneMonthBefore = oneMonthBefore[...(-1)]
        let fetchPopularTitles = Requests.Manga.query(
            params: [
                "order[followedCount]": "desc",
                "hasAvailableChapters": true,
                "createdAtSince": oneMonthBefore,
                "limit": 10
            ])
        let fetchLatest = Requests.Chapter.query(
            params: [
                "order[readableAt]": "desc",
                "limit": 21
            ])
        let fetchSeasonal = Requests.CustomList.get(id: "77430796-6625-4684-b673-ffae5140f337")
        let fetchRecentlyAdded = Requests.Manga.query(
            params: [
                "order[createdAt]": "desc",
                "hasAvailableChapters": true,
                "limit": 15
            ])
        firstly {
            when(fulfilled: fetchPopularTitles, fetchLatest, fetchSeasonal, fetchRecentlyAdded)
        }.done { popularCollection, updatesCollection, seasonalListModel, recentCollection in
            self.popularTitles = popularCollection.data
            self.recentTitles = recentCollection.data
            self.latestChapters = updatesCollection.data
            var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, String>()
            snapshot.appendSections([.popular, .updates, .seasonal, .added])
            snapshot.appendItems(self.popularTitles.map({ mangaModel in mangaModel.id }),
                                 toSection: .popular)
            snapshot.appendItems(self.latestChapters.map({ chapterModel in chapterModel.id }),
                                 toSection: .updates)
            snapshot.appendItems(self.recentTitles.map({ mangaModel in mangaModel.id }),
                                 toSection: .added)
            Requests.Manga
                .query(params: ["ids[]": seasonalListModel.mangaIds])
                .done { seasonalCollection in
                    self.seasonalTitles = seasonalCollection.data
                    snapshot.appendItems(
                        self.seasonalTitles.map({ mangaModel in mangaModel.id }),
                        toSection: .seasonal)
                    self.dataSource.apply(snapshot, animatingDifferences: true)
                    self.collectionHeaderView.setRefreshing(false)
                }
                .catch { error in
                    self.collectionHeaderView.setRefreshing(false)
                }
        }.catch { error in
            ProgressHUD.showError()
        }
    }
}

extension BrowseMangaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch SectionLayoutKind(rawValue: indexPath.section)! {
        case .popular:
            let mangaModel = popularTitles[indexPath.item]
            let vc = MangaTitleViewController(mangaModel: mangaModel)
//            let vc = MangaDetailViewController(mangaModel: mangaModel)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .updates:
            let chapterModel = latestChapters[indexPath.item]
            if let externUrl = chapterModel.attributes.externalUrl,
               let url = URL(string: externUrl) {
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true)
            }
            else if let mangaModel = chapterModel.mangaModel {
                let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterModel.id)
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .seasonal:
            let mangaModel = seasonalTitles[indexPath.item]
            let vc = MangaTitleViewController(mangaModel: mangaModel)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .added:
            let mangaModel = recentTitles[indexPath.item]
            let vc = MangaTitleViewController(mangaModel: mangaModel)
            navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
}
