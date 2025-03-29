//
//  DownloadingViewController.swift
//  Mangadex
//
//  Created by John Rion on 2025/03/16.
//

import Foundation
import UIKit
import SnapKit
import MJRefresh

class DownloadingViewController: BaseViewController {
    private var refreshHeader: MJRefreshNormalHeader!
    private var collectionView: UICollectionView!
    private var activeDownloads: [ChapterDownload] = []
    
    override func setupUI() {
        setupNavBar(title: "mypage.downloading.title".localized())
        refreshHeader = MJRefreshNormalHeader { [unowned self] in
            self.updateDownloads()
        }
        setupCollectionView()
    }
    
    override func didSetupUI() {
        // Listen for download status updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateDownloads),
            name: .downloadStatusChanged,
            object: nil)
        
        // Load initial data
        updateDownloads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDownloads()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 80)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DownloadCell.self, forCellWithReuseIdentifier: "DownloadCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.mj_header = refreshHeader
        collectionView.mj_header?.ignoredScrollViewContentInsetTop = 10
        collectionView.contentInset = .vertical(10)
        
        view.insertSubview(collectionView, belowSubview: appBar)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(appBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc private func updateDownloads() {
        activeDownloads = DownloadManager.shared.getActiveDownloads()
        Task { @MainActor in
            collectionView.reloadData()
            refreshHeader.endRefreshing()
        }
    }
}

extension DownloadingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeDownloads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownloadCell", for: indexPath) as! DownloadCell
        let chapter = activeDownloads[indexPath.row]
        cell.configure(with: chapter)
        return cell
    }
}
