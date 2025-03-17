//
//  DownloadCell.swift
//  Mangadex
//
//  Created by John Rion on 2025/03/16.
//

import Foundation
import UIKit

class DownloadCell: UICollectionViewCell {
    private var chapterID: String?
    private var chapterDownload: ChapterDownload?
    private let mangaTitleLabel = UILabel()
    private let chapterTitleLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let actionButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(code:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .lighterGrayEFEFEF
        layer.cornerRadius = 8
        clipsToBounds = true
        
        addSubview(cancelButton)
        cancelButton.tintColor = .black2D2E2F
        cancelButton.setImage(UIImage(named: "icon_close"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelDownload), for: .touchUpInside)
        cancelButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.top.right.equalToSuperview().inset(10)
        }
        
        addSubview(actionButton)
        actionButton.tintColor = .darkerGray565656
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        actionButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.right.bottom.equalToSuperview().inset(10)
        }
        
        addSubview(mangaTitleLabel)
        mangaTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        mangaTitleLabel.textColor = .darkGray808080
        mangaTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(actionButton.snp.left).offset(-10)
        }
        
        addSubview(chapterTitleLabel)
        chapterTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        chapterTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(mangaTitleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(mangaTitleLabel)
        }
        
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(10)
            make.right.equalTo(mangaTitleLabel)
        }
    }
    
    func configure(with chapter: ChapterDownload) {
        chapterID = chapter.id
        chapterDownload = chapter
        mangaTitleLabel.text = chapter.mangaModel.attributes.localizedTitle
        chapterTitleLabel.text = chapter.chapterModel.attributes.fullChapterName
        progressView.progress = Float(chapter.progress)
        chapter.progressHandler = { [weak self] progress in
            self?.progressView.progress = Float(chapter.progress)
        }
        
        switch chapter.status {
        case .waiting, .preparing:
            actionButton.setImage(UIImage(named: "icon_schedule"), for: .normal)
            actionButton.isUserInteractionEnabled = false
        case .running:
            actionButton.setImage(UIImage(named: "icon_pause"), for: .normal)
            actionButton.isUserInteractionEnabled = true
        case .paused:
            actionButton.setImage(UIImage(named: "icon_play"), for: .normal)
            actionButton.isUserInteractionEnabled = true
        case .failed:
            actionButton.setImage(UIImage(named: "icon_error"), for: .normal)
            actionButton.isUserInteractionEnabled = true
        case .succeeded:
            actionButton.isUserInteractionEnabled = false
        }
    }
    
    @objc private func handleAction() {
        switch chapterDownload?.status {
        case .waiting, .preparing, .succeeded, nil:
            break
        case .running:
            pauseDownload()
        case .paused:
            resumeDownload()
        case .failed:
            retryDownload()
        }
    }
    
    @objc private func cancelDownload() {
        guard let chapterID else { return }
        DownloadManager.shared.cancelChapterDownload(chapterID: chapterID)
    }
    
    private func pauseDownload() {
        guard let chapterID else { return }
        DownloadManager.shared.pauseChapterDownload(chapterID: chapterID)
    }
    
    private func resumeDownload() {
        guard let chapterID else { return }
        DownloadManager.shared.resumeChapterDownload(chapterID: chapterID)
    }
    
    private func retryDownload() {
        guard let chapterID else { return }
        DownloadManager.shared.retryChapterDownload(chapterID: chapterID)
    }
}
