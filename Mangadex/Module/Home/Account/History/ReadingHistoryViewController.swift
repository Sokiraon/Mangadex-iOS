//
//  ReadingHistoryViewController.swift
//  Mangadex
//
//  Created by John Rion on 2025/12/20.
//

import UIKit
import SnapKit
import ProgressHUD

class ReadingHistoryViewController: BaseViewController, UICollectionViewDelegate {
    enum SectionKind: Int {
        case entries
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionKind, String>!
    private let emptyStateLabel = UILabel(
        fontSize: 16,
        color: .secondaryText,
        alignment: .center,
        numberOfLines: 0
    ).apply { label in
        label.text = String(localized: "No reading history yet")
        label.isHidden = true
    }
    private let historyActor = ReadingHistoryModelActor(
        modelContainer: AppDataContainer.shared.container
    )
    private var history: [ReadingHistoryDTO] = []
    private var isOpeningEntry = false
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .clear
        listConfig.showsSeparators = false
        
        listConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil}
            
            let mangaId = dataSource.itemIdentifier(for: indexPath)
            
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: nil
            ) { _, _, completion in
                guard let mangaId else {
                    completion(false)
                    return
                }
                self.deleteHistoryItem(for: mangaId, completion: completion)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    override func setupUI() {
        setupNavBar(title: String(localized: .readingHistory))
        
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.delegate = self
        collectionView.backgroundColor = .lightestGrayF5F5F5
        collectionView.contentInset =
            .cssStyle(8, 0, MDLayout.adjustedSafeInsetBottom)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(appBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }

        view.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
    }
    
    override func didSetupUI() {
        setupDataSource()
        fetchReadingHistory()
    }
    
    private func setupDataSource() {
        let entryCellRegistration = UICollectionView.CellRegistration<
            ReadingHistoryCollectionCell, String
        > { [weak self] cell, indexPath, itemIdentifier in
            guard let self else { return }
            guard let entry = self.entry(for: itemIdentifier) else {
                return
            }
            cell.setContent(with: entry)
            cell.onContinue = { [weak self] in
                self?.openReadingEntry(entry)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            guard let section = SectionKind(rawValue: indexPath.section) else {
                return nil
            }
            switch section {
            case .entries:
                return collectionView
                    .dequeueConfiguredReusableCell(
                        using: entryCellRegistration,
                        for: indexPath,
                        item: itemIdentifier
                    )
            }
        }
    }
    
    private func fetchReadingHistory() {
        Task {
            let result = (try? await historyActor.fetchHistories()) ?? []
            await MainActor.run {
                self.history = result
                self.applySnapshot()
            }
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, String>()
        snapshot.appendSections([.entries])
        snapshot.appendItems(history.map { $0.mangaId }, toSection: .entries)
        dataSource.apply(snapshot, animatingDifferences: true)
        emptyStateLabel.isHidden = !history.isEmpty
    }

    private func entry(for mangaId: String) -> ReadingHistoryDTO? {
        history.first(where: { $0.mangaId == mangaId })
    }

    private func openReadingEntry(_ entry: ReadingHistoryDTO) {
        guard !isOpeningEntry else { return }
        isOpeningEntry = true

        if let localEntry = DownloadManager.shared.retrieveChapter(
            mangaID: entry.mangaId,
            chapterID: entry.chapterId
        ) {
            let vc = DownloadedMangaViewer(
                mangaModel: localEntry.manga,
                chapterModel: localEntry.chapter
            )
            navigationController?.pushViewController(vc, animated: true)
            isOpeningEntry = false
            return
        }

        ProgressHUD.animate()
        Task {
            do {
                let mangaModel = try await Requests.Manga.get(id: entry.mangaId)
                await MainActor.run {
                    ProgressHUD.dismiss()
                    let vc = OnlineMangaViewer(
                        mangaModel: mangaModel,
                        chapterId: entry.chapterId
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.isOpeningEntry = false
                }
            } catch {
                await MainActor.run {
                    ProgressHUD.failed()
                    self.isOpeningEntry = false
                }
            }
        }
    }

    private func openMangaDetail(_ entry: ReadingHistoryDTO) {
        guard !isOpeningEntry else { return }
        isOpeningEntry = true

        ProgressHUD.animate()
        Task {
            do {
                let mangaModel = try await Requests.Manga.get(id: entry.mangaId)
                await MainActor.run {
                    ProgressHUD.dismiss()
                    let vc = MangaTitleViewController(mangaModel: mangaModel)
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.isOpeningEntry = false
                }
            } catch {
                await MainActor.run {
                    ProgressHUD.failed()
                    self.isOpeningEntry = false
                }
            }
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let mangaId = dataSource.itemIdentifier(for: indexPath),
            let entry = entry(for: mangaId)
        else {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        openMangaDetail(entry)
    }

    private func deleteHistoryItem(
        for mangaId: String,
        completion: @escaping (Bool) -> Void
    ) {
        Task {
            do {
                try await historyActor.deleteHistory(for: mangaId)
                await MainActor.run {
                    self.history.removeAll { $0.mangaId == mangaId }
                    self.applySnapshot()
                    completion(true)
                }
            } catch {
                await MainActor.run {
                    ProgressHUD.failed()
                    completion(false)
                }
            }
        }
    }
}
