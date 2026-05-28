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
    private let collectionCardView = CardView().apply { view in
        view.cornerRadius = 16
        view.shadowCornerRadius = 16
        view.shadowOpacity = 0.14
    }
    private let headerView = UIView()
    private lazy var sortButton = UIButton(
        configuration: sortButtonConfiguration,
        primaryAction: UIAction { [weak self] _ in
            self?.toggleChapterSortOrder()
        }
    )
    private lazy var filterButton = UIButton(configuration: makeHeaderButtonConfiguration(
        title: String(localized: "Filter"),
        image: UIImage(systemName: "line.3.horizontal.decrease.circle")
    ))
    private let headerDivider = LineView()
    private var chapterSortOrder: Requests.Chapter.Order = .desc

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
        config.contentInsets = .cssStyle(8, 18)
        return config
    }

    private func makeHeaderButtonConfiguration(
        title: String,
        image: UIImage?
    ) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = image
        config.imagePadding = 8
        config.preferredSymbolConfigurationForImage = .init(pointSize: 12)
        config.baseForegroundColor = .black2D2E2F
        config.contentInsets = .cssStyle(8, 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 15, weight: .medium)
            return outgoing
        }
        return config
    }

    private var sortButtonConfiguration: UIButton.Configuration {
        switch chapterSortOrder {
        case .asc:
            makeHeaderButtonConfiguration(
                title: String(localized: "Ascending"),
                image: UIImage(systemName: "arrow.up")
            )
        case .desc:
            makeHeaderButtonConfiguration(
                title: String(localized: "Descending"),
                image: UIImage(systemName: "arrow.down")
            )
        }
    }

    private func toggleChapterSortOrder() {
        chapterSortOrder = chapterSortOrder == .desc ? .asc : .desc
        sortButton.configuration = sortButtonConfiguration
        fetchChapters()
    }
    
    override func setupUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .cssStyle(8, 0)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.layer.cornerRadius = 16
        
        view.addSubview(collectionCardView)
        collectionCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(64)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        collectionCardView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(48)
        }

        headerView.addSubview(sortButton)
        sortButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }

        headerView.addSubview(filterButton)
        filterButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }

        headerView.addSubview(headerDivider)
        headerDivider.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        collectionCardView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
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
            make.top.equalTo(collectionCardView).offset(40)
            make.left.right.bottom.equalTo(collectionCardView)
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
        let requestedOrder = chapterSortOrder
        Task {
            do {
                await MainActor.run {
                    self.setErrorStateVisible(false)
                }

                let chapterCollection = try await Requests.Chapter
                    .getMangaFeed(mangaID: mangaId, order: requestedOrder)
                let readChapters = (try? await Requests.Manga
                    .getReadChapters(mangaID: mangaId)) ?? []

                guard requestedOrder == self.chapterSortOrder else {
                    return
                }

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
                    guard requestedOrder == self.chapterSortOrder else {
                        return
                    }
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
        collectionCardView.isHidden = isVisible
    }
    
    func loadMoreChapters() {
        let requestedOrder = chapterSortOrder
        Task {
            let chapterCollection = try await Requests.Chapter.getMangaFeed(
                mangaID: mangaModel.id,
                offset: chapterModels.count,
                order: requestedOrder
            )
            guard requestedOrder == chapterSortOrder else {
                return
            }
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
