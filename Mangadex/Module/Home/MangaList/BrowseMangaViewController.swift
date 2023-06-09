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

class BrowseMangaViewController: BaseViewController {
    
    enum SectionLayoutKind: Int {
        case popular
        case recent
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, String>!
    
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let sectionKind = SectionLayoutKind(rawValue: sectionIndex) else {
                return nil
            }
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize, elementKind: .sectionHeaderElementKind, alignment: .top)
            switch sectionKind {
            case .popular:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(MDLayout.screenWidth - 24),
                                                       heightDimension: .absolute(256))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])
                group.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 0)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            case .recent:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .absolute(105))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(MDLayout.screenWidth - 24),
                                                       heightDimension: .estimated(351))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             repeatingSubitem: item,
                                                             count: 3)
                group.interItemSpacing = .fixed(10)
                group.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 0)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            }
        }
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
    private var recentTitles = [MangaModel]()
    
    private func configureDataSource() {
        let popularCellRegistration = UICollectionView.CellRegistration<PopularMangaCollectionCell, String>
        { cell, indexPath, identifier in
            cell.setContent(mangaModel: self.popularTitles[indexPath.item])
        }
        
        let recentCellRegistration = UICollectionView.CellRegistration<MangaListCollectionCell, String>
        { cell, indexPath, identifier in
            cell.setContent(mangaModel: self.recentTitles[indexPath.item])
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<BrowseMangaTitleSupplementaryView>(
            elementKind: .sectionHeaderElementKind) { supplementaryView, elementKind, indexPath in
            switch SectionLayoutKind(rawValue: indexPath.section)! {
            case .popular:
                supplementaryView.label.text = "browse.section.popular".localized()
                break
            case .recent:
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
            case .recent:
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
        let fetchRecentlyAdded = Requests.Manga.query(
            params: [
                "order[createdAt]": "desc",
                "limit": 15
            ])
        firstly {
            when(fulfilled: fetchPopularTitles, fetchRecentlyAdded)
        }.done { popularCollection, recentCollection in
            self.popularTitles = popularCollection.data
            self.recentTitles = recentCollection.data
            var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, String>()
            snapshot.appendSections([.popular, .recent])
            snapshot.appendItems(self.popularTitles.map({ mangaModel in mangaModel.id }),
                                 toSection: .popular)
            snapshot.appendItems(self.recentTitles.map({ mangaModel in mangaModel.id }),
                                 toSection: .recent)
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.collectionHeaderView.setRefreshing(false)
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
            let vc = MDMangaDetailViewController(mangaModel: mangaModel)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .recent:
            let mangaModel = recentTitles[indexPath.item]
            let vc = MDMangaDetailViewController(mangaModel: mangaModel)
            navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
}
