//
//  MangaTitleChaptersViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/27.
//

import Foundation
import UIKit
import SnapKit

class MangaTitleChaptersViewController: BaseViewController {

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

    private lazy var errorStateView = UIView().apply { view in
        view.isHidden = true
    }

    private let errorImageView = UIImageView().apply { imageView in
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.tintColor = .secondaryText
        imageView.contentMode = .scaleAspectFit
    }

    private let errorTitleLabel = UILabel(
        fontSize: 17,
        fontWeight: .medium,
        color: .primaryText,
        alignment: .center
    ).apply { label in
        label.text = String(localized: "Couldn't load chapters")
    }

    private let errorMessageLabel = UILabel(
        fontSize: 14,
        color: .secondaryText,
        alignment: .center,
        numberOfLines: 0
    )

    private lazy var retryButton = UIButton(
        configuration: retryButtonConfiguration,
        primaryAction: UIAction { [weak self] _ in
            self?.fetchChapters()
        }
    )

    private var retryButtonConfiguration: UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = String(localized: "Retry")
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .themePrimary
        config.cornerStyle = .small
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 18,
            bottom: 8,
            trailing: 18
        )
        return config
    }
    
    override func setupUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .cssStyle(8, 0, MDLayout.adjustedSafeInsetBottom)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.left.right.bottom.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }

        let errorStack = UIStackView(arrangedSubviews: [
            errorImageView,
            errorTitleLabel,
            errorMessageLabel,
            retryButton
        ])
        errorStack.axis = .vertical
        errorStack.alignment = .center
        errorStack.spacing = 10

        view.addSubview(errorStateView)
        errorStateView.snp.makeConstraints { make in
            make.top.equalTo(collectionView).offset(40)
            make.left.right.bottom.equalTo(collectionView)
        }

        errorStateView.addSubview(errorStack)
        errorStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-30)
            make.left.right.equalToSuperview().inset(32)
        }

        errorImageView.snp.makeConstraints { make in
            make.size.equalTo(36)
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
        let mangaId = mangaModel.id!
        Task {
            do {
                await MainActor.run {
                    self.setErrorStateVisible(false)
                }

                let chapterCollection = try await Requests.Chapter
                    .getMangaFeed(mangaID: mangaId)
                let readChapters = (try? await Requests.Manga
                    .getReadChapters(mangaID: mangaId)) ?? []

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
            } catch {
                await MainActor.run {
                    self.showFetchError(error)
                }
            }
        }
    }

    private func showFetchError(_ error: Error) {
        errorMessageLabel.text = error.localizedDescription
        setErrorStateVisible(true)
    }

    private func setErrorStateVisible(_ isVisible: Bool) {
        errorStateView.isHidden = !isVisible
        collectionView.isHidden = isVisible
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
            guard let readChapters = try? await Requests.Manga
                .getReadChapters(mangaID: mangaModel.id)
            else {
                return
            }
            self.readChapters = readChapters
            await self.dataSource
                .applySnapshotUsingReloadData(self.dataSource.snapshot())
        }
    }
    
    func viewChapter(at indexPath: IndexPath) {
        let chapterModel = chapterModels[indexPath.item]
        let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterModel.id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
