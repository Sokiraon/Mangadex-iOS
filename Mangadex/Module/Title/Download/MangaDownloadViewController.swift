//
//  MangaDownloadViewController.swift
//  Mangadex
//
//  Created by John Rion on 2024/06/19.
//

import Foundation
import UIKit
import SnapKit
import Combine

class MangaDownloadViewController: BaseViewController {
    // MARK: - Stored Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI components
    private let bottomView = UIView()
    private let bottomLineView = LineView(axis: .horizontal)
    private var downloadButton: UIButton!
    private lazy var collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // MARK: - Lifecycle
    convenience init(mangaModel: MangaModel) {
        self.init()
        self.mangaModel = mangaModel
    }
    
    override func setupUI() {
        setupNavBar(title: "manga.download.title".localized())
        
        view.insertSubview(collectionView, belowSubview: appBar)
        collectionView.delegate = self
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(appBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        view.insertSubview(bottomView, aboveSubview: collectionView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom)
        }
        
        bottomView.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "manga.download.start".localized()
        buttonConfig.baseForegroundColor = .white
        buttonConfig.baseBackgroundColor = .themePrimary
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .small
        downloadButton = UIButton(configuration: buttonConfig,
                                  primaryAction: UIAction { _ in self.startDownload() })
        bottomView.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.top.equalTo(bottomLineView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(MDLayout.adjustedSafeInsetBottom)
        }
    }
    
    override func didSetupUI() {
        setupDataSource()
        fetchChapters()
        
        $checkedChapterModels
            .sink { [weak self] models in
                guard let self else { return }
                downloadButton.isEnabled = !models.isEmpty
            }
            .store(in: &cancellables)
    }
    
    // MARK: - CollectionView
    
    private enum SectionLayoutKind: Int {
        case chapters
        case loader
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let sectionKind = SectionLayoutKind(rawValue: sectionIndex) else {
                return nil
            }
            switch sectionKind {
            case .chapters:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4),
                                                      heightDimension: .estimated(36))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .estimated(48))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])
                group.interItemSpacing = .fixed(12)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 12, leading: 20, bottom: 16, trailing: 20)
                return section
            case .loader:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(48))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .estimated(48))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
        
        return layout
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, String>!
    
    private func setupDataSource() {
        let chapterCellRegistration = UICollectionView.CellRegistration<MangaDownloadChapterCell, String>
        { cell, indexPath, itemIdentifier in
            let chapterModel = self.chapterModels[indexPath.item]
            cell.setTitle(chapterModel.attributes.chapter ?? "")
            cell.setChecked(self.checkedChapterModels.contains(chapterModel), animated: false)
            cell.setIsDownloading(DownloadManager.shared.hasActiveDownload(for: chapterModel.id))
            cell.setHasDownloaded(DownloadManager.shared.hasDownloaded(chapterID: chapterModel.id, for: self.mangaModel.id))
        }
        
        let loaderCellRegistration = UICollectionView.CellRegistration<CollectionLoaderCell, String>
        { _, _, _ in }
        
//        let headerRegistration = UICollectionView.SupplementaryRegistration<MangaDownloadVolumeHeaderView>(
//            elementKind: UICollectionView.elementKindSectionHeader)
//        { supplementaryView, elementKind, indexPath in
//            
//        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            switch SectionLayoutKind(rawValue: indexPath.section)! {
            case .chapters:
                collectionView.dequeueConfiguredReusableCell(
                    using: chapterCellRegistration, for: indexPath, item: itemIdentifier)
            case .loader:
                collectionView.dequeueConfiguredReusableCell(
                    using: loaderCellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
//        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
//            collectionView.dequeueConfiguredReusableSupplementary(
//                using: headerRegistration, for: indexPath)
//        }
    }
    
    // MARK: - Data
    private var mangaModel: MangaModel!
    private var chapterModels = [ChapterModel]()
    private var chaptersCount = 0
    
    @Published private var checkedChapterModels = Set<ChapterModel>()
    
    private let loaderID = UUID().uuidString
    
    private func fetchChapters() {
        Task {
            let chapterCollection = try await Requests.Chapter.getMangaFeed(mangaID: mangaModel.id)
            self.chapterModels = chapterCollection.data
            self.chaptersCount = chapterCollection.total
            
            var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, String>()
            snapshot.appendSections([.chapters, .loader])
            snapshot.appendItems(chapterCollection.data.map { $0.id },
                                 toSection: .chapters)
            if chapterCollection.data.count < chapterCollection.total {
                snapshot.appendItems([self.loaderID], toSection: .loader)
            }
            await self.dataSource.apply(snapshot)
        }
    }
    
    private func loadMoreChapters() {
        Task {
            let chapterCollection = try await Requests.Chapter.getMangaFeed(mangaID: mangaModel.id, offset: chapterModels.count)
            self.chapterModels.append(contentsOf: chapterCollection.data)
            self.chaptersCount = chapterCollection.total
            
            var snapshot = self.dataSource.snapshot()
            snapshot.appendItems(chapterCollection.data.map { $0.id }, toSection: .chapters)
            if self.chapterModels.count >= self.chaptersCount {
                snapshot.deleteItems([loaderID])
            }
            await self.dataSource.apply(snapshot)
        }
    }
    
    // MARK: - Actions
    func startDownload() {
        DownloadManager.shared.downloadManga(mangaModel: mangaModel, chapterModels: Array(checkedChapterModels))
        let vc = DownloadingViewController()
        self.navigationController?.replaceTopViewController(with: vc, animated: true)
    }
}

extension MangaDownloadViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is CollectionLoaderCell {
            loadMoreChapters()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MangaDownloadChapterCell else { return }
        if cell.checked {
            cell.setChecked(false, animated: true)
            checkedChapterModels.remove(chapterModels[indexPath.item])
        } else {
            cell.setChecked(true, animated: true)
            checkedChapterModels.insert(chapterModels[indexPath.item])
        }
    }
}
