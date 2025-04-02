//
//  MangaTitleChaptersViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/27.
//

import Foundation
import UIKit
import SnapKit
import MJRefresh
import PromiseKit

class MangaTitleChaptersViewController: BaseViewController {
    
    lazy var refreshHeader = MJRefreshNormalHeader { [unowned self] in
        self.fetchChapters()
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.contentInsets = .zero
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    lazy var collectionView = ChildCollectionView(
        frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    override func setupUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .cssStyle(8, 0, MDLayout.adjustedSafeInsetBottom)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.left.right.bottom.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        setupDataSource()
        fetchChapters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateReadChapters()
    }
    
    enum CollectionSection: Int {
        case chapters
        case loader
    }
    
    var dataSource: UICollectionViewDiffableDataSource<CollectionSection, String>!
    
    func setupDataSource() {
        let chapterCellRegistration = UICollectionView.CellRegistration<MangaChapterCollectionCell, String>
        { [weak self] cell, indexPath, itemIdentifier in
            guard let self else { return }
            let chapterModel = self.chapterModels[indexPath.item]
            cell.setContent(with: chapterModel, viewed: self.readChapters.contains(chapterModel.id))
        }
        
        let loaderCellRegistration = UICollectionView.CellRegistration<CollectionLoaderCell, String>
        { _, _, _ in }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            switch CollectionSection(rawValue: indexPath.section)! {
            case .chapters:
                return collectionView.dequeueConfiguredReusableCell(
                    using: chapterCellRegistration, for: indexPath, item: itemIdentifier)
            case .loader:
                return collectionView.dequeueConfiguredReusableCell(
                    using: loaderCellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
    }
    
    var chapterModels = [ChapterModel]()
    var totalChapters = 0
    var readChapters = [String]()
    
    var mangaModel: MangaModel!
    let loadingCellIdentifier = UUID().uuidString
    
    func fetchChapters() {
        Task {
            async let request1 = Requests.Chapter.getMangaFeed(mangaID: mangaModel.id)
            async let request2 = Requests.Manga.getReadChapters(mangaID: mangaModel.id)
            let (chapterCollection, readChapters) = try await (request1, request2)
            
            self.chapterModels = chapterCollection.data
            self.totalChapters = chapterCollection.total
            self.readChapters = readChapters
            
            var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, String>()
            snapshot.appendSections([.chapters, .loader])
            snapshot.appendItems(chapterCollection.data.map { $0.id }, toSection: .chapters)
            if chapterCollection.data.count < chapterCollection.total {
                snapshot.appendItems([self.loadingCellIdentifier],
                                     toSection: .loader)
            }
            await self.dataSource.apply(snapshot)
        }
    }
    
    func loadMoreChapters() {
        Task {
            let chapterCollection = try await Requests.Chapter.getMangaFeed(mangaID: mangaModel.id, offset: chapterModels.count)
            self.chapterModels.append(contentsOf: chapterCollection.data)
            self.totalChapters = chapterCollection.total
            
            var snapshot = self.dataSource.snapshot()
            snapshot.appendItems(chapterCollection.data.map { $0.id }, toSection: .chapters)
            if self.chapterModels.count >= chapterCollection.total {
                snapshot.deleteItems([self.loadingCellIdentifier])
            }
            await self.dataSource.apply(snapshot)
        }
    }
    
    private func updateReadChapters() {
        Task {
            let readChapters = try await Requests.Manga.getReadChapters(mangaID: mangaModel.id)
            self.readChapters = readChapters
            await self.dataSource.applySnapshotUsingReloadData(self.dataSource.snapshot())
        }
    }
    
    func viewChapter(at indexPath: IndexPath) {
        let chapterModel = chapterModels[indexPath.item]
        let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterModel.id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
