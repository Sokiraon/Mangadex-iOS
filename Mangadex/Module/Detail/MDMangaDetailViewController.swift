//
//  MDMangaDetailViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/1.
//

import Foundation
import UIKit
import SwiftEventBus
import SwiftTheme
import PromiseKit
import ProgressHUD
import SnapKit
import MJRefresh
import TTTAttributedLabel
import SafariServices
import MarkdownKit

private class MyCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

private class MangaDescrMoreView: UIView {
    private let lblMore = UILabel(fontSize: 15)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(lblMore)
        lblMore.backgroundColor = .clear
        lblMore.text = "kMangaDetailDescrMore".localized()
        lblMore.theme_textColor = UIColor.theme_darkColor
        lblMore.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(1)
        }
        
        backgroundColor = .white
        layer.masksToBounds = false
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .init(width: -8, height: 0)
        layer.shadowRadius = 3
    }
}

class MDMangaDetailViewController: MDViewController, TTTAttributedLabelDelegate {
    
    private var btnFollowConfFollowed: UIButton.Configuration!
    private var btnFollowConfUnFollowed: UIButton.Configuration!
    
    private lazy var btnFollow = UIButton(
        type: .custom,
        primaryAction: UIAction { _ in
        }
    ).apply { button in
        var btnConfCommon = UIButton.Configuration.gray()
        btnConfCommon.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        btnConfCommon.imagePadding = 4
        
        btnFollowConfFollowed = btnConfCommon
        btnFollowConfFollowed.title = "kMangaActionFollowed".localized()
        btnFollowConfFollowed.image = .init(named: "icon_bookmark")
        btnFollowConfFollowed.baseForegroundColor = .black2D2E2F
        
        btnFollowConfUnFollowed = btnConfCommon
        btnFollowConfUnFollowed.title = "kMangaActionToFollow".localized()
        btnFollowConfUnFollowed.image = .init(named: "icon_bookmark_border")
        btnFollowConfUnFollowed.baseForegroundColor = .white
        btnFollowConfUnFollowed.baseBackgroundColor = .cerulean400
        
        button.configuration = btnFollowConfUnFollowed
    }
    
    private var mangaItem: MangaItem!
    
    private lazy var refreshHeader = MJRefreshNormalHeader {
        self.fetchData()
    }
    private let vScroll = UIScrollView()
    
    private lazy var vHeader = MDMangaDetailHeaderView(mangaItem: self.mangaItem)
    private let lblDescr = TTTAttributedLabel()
    private lazy var vDescrMore = MangaDescrMoreView()
    
    private let vDivider = UIView(style: .line)
    
    private let lblChapters = UILabel(fontSize: 20, fontWeight: .medium)
    
    private var chapterModels = [MDMangaChapterInfoModel]()
    private var totalChapters: Int!
    
    private var vChapters: MyCollectionView!
    
    // MARK: - Initialization
    convenience init(mangaItem: MangaItem) {
        self.init()
        self.mangaItem = mangaItem
    }
    
    override func setupUI() {
        setupNavBar()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        vScroll.delegate = self
        vScroll.delaysContentTouches = false
        vScroll.showsVerticalScrollIndicator = false
        vScroll.mj_header = refreshHeader
        
        view.addSubview(vScroll)
        vScroll.snp.makeConstraints { make in
            make.top.equalTo(appBar!.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        vScroll.addSubview(vHeader)
        vHeader.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        vScroll.addSubview(lblDescr)
        lblDescr.snp.makeConstraints { make in
            make.top.equalTo(vHeader.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }
        let parser = MarkdownParser()
        parser.link.color = UIColor.themeDark
        let descrStr = NSMutableAttributedString(
            attributedString: parser.parse(mangaItem.description)
        )
        let fontToUse = UIFont.systemFont(ofSize: 15)
        descrStr.addAttributes(
            [.font: fontToUse],
            range: .init(location: 0, length: descrStr.length)
        )
        lblDescr.text = descrStr
        lblDescr.numberOfLines = 3
        lblDescr.delegate = self
        
        let labelWidth = MDLayout.screenWidth - 16 * 2
        let constrainedSize = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        let rect = descrStr.boundingRect(
            with: constrainedSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let lines = Int(ceil(rect.height / fontToUse.lineHeight))
        if lines > 3 {
            vScroll.insertSubview(vDescrMore, aboveSubview: lblDescr)
            vDescrMore.snp.makeConstraints { make in
                make.right.bottom.equalTo(lblDescr)
            }
            vDescrMore.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(expandDescrption))
            )
        }
        
        vScroll.addSubview(btnContinue)
        btnContinue.layer.cornerRadius = 22
        btnContinue.setTitle("kMangaActionStartOver".localized(), for: .normal)
        btnContinue.snp.makeConstraints { make in
            make.top.equalTo(lblDescr.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        vScroll.addSubview(vDivider)
        vDivider.snp.makeConstraints { make in
            make.top.equalTo(btnContinue.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        vScroll.addSubview(lblChapters)
        lblChapters.text = "kMangaDetailChapters".localized()
        lblChapters.snp.makeConstraints { make in
            make.top.equalTo(vDivider.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = .init(
            width: (MDLayout.screenWidth - 2 * 16 - 3 * 10) / 4, height: 45
        )
        vChapters = MyCollectionView(
            frame: .zero, collectionViewLayout: collectionLayout
        )
        vChapters.delegate = self
        vChapters.dataSource = self
        vChapters.contentInset = .cssStyle(0, 16, MDLayout.adjustedSafeInsetBottom)
        vChapters.showsVerticalScrollIndicator = false
        vChapters.register(
            MDMangaDetailChapterCollectionCell.self, forCellWithReuseIdentifier: "chapter"
        )
        
        vScroll.addSubview(vChapters)
        vChapters.snp.makeConstraints { make in
            make.top.equalTo(lblChapters.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(view)
        }
    }
    
    override func didSetupUI() {
        vScroll.mj_header?.beginRefreshing()
    }
    
    // MARK: - Button Continue
    
    private var lastViewedChapterId: String?
    private var lastViewedChapterIndex = IndexPath(row: 0, section: 0)
    
    private lazy var btnContinue = UIButton(
        type: .system,
        primaryAction: UIAction { _ in
            self.viewManga(atIndexPath: self.lastViewedChapterIndex)
        }
    ).apply { button in
        button.theme_backgroundColor = UIColor.theme_primaryColor
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
    }
    
    override func doOnAppear() {
        lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: mangaItem.id)
        if lastViewedChapterId != nil {
            btnContinue.setTitle("kMangaActionContinue".localized(), for: .normal)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Actions
    @objc private func expandDescrption() {
        lblDescr.numberOfLines = 0
        vDescrMore.removeFromSuperview()
        UIView.animate(withDuration: 0.3) {
            self.lblDescr.sizeToFit()
            self.vScroll.layoutIfNeeded()
        }
    }
    
    private func fetchData() {
        _ = firstly {
            when(fulfilled: MDRequests.Manga.getReadingStatus(mangaId: mangaItem.id),
                 MDRequests.Chapter.getListForManga(
                     mangaId: mangaItem.id,
                     offset: 0,
                     locale: MDLocale.currentMangaLanguage,
                     order: .ASC
                 )
            )
        }.done { readingStatus, chapters in
            self.chapterModels = chapters.data
            self.totalChapters = chapters.total
            
            DispatchQueue.main.async {
                self.vChapters.reloadData()
                self.vHeader.update(readingStatus: readingStatus)
            }
        }.ensure {
            DispatchQueue.main.async {
                self.vScroll.mj_header?.endRefreshing()
            }
        }
    }
    
    private func loadMoreChapters() {
        _ = firstly {
            MDRequests.Chapter.getListForManga(
                mangaId: mangaItem.id,
                offset: chapterModels.count,
                locale: MDLocale.currentMangaLanguage,
                order: .ASC
            )
        }.done { result in
            DispatchQueue.main.async {
                self.chapterModels.append(contentsOf: result.data)
                self.totalChapters = result.total
                
                self.vChapters.reloadData()
                self.vChapters.mj_footer?.endRefreshing()
                
                if self.chapterModels.count == self.totalChapters {
                    self.vChapters.mj_footer?.isHidden = true
                }
            }
        }
    }
    
    private func viewManga(atIndexPath indexPath: IndexPath) {
        let vc = MDMangaSlideViewController(
            chapterInfo: chapterModels[indexPath.row],
            currentIndex: indexPath.row,
            requirePrevAction: { index in
                index > 0 ? self.chapterModels[index - 1] : nil
            },
            requireNextAction: { index in
                index < self.chapterModels.count - 1 ? self.chapterModels[index + 1] : nil
            },
            enterPageAction: { chapterId in
                MDMangaProgressManager.saveProgress(forMangaId: self.mangaItem.id, chapterId: chapterId)
            },
            leavePageAction: {
                self.lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: self.mangaItem.id)
                self.vChapters.reloadData()
            }
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true)
    }
}

// MARK: - CollectionView Delegate
extension MDMangaDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chapterModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "chapter",
            for: indexPath
        ) as! MDMangaDetailChapterCollectionCell
        
        let model = chapterModels[indexPath.row]
        let lastViewed = model.id == lastViewedChapterId
        if lastViewed {
            lastViewedChapterIndex = indexPath
        }
        cell.update(model: model, lastViewed: lastViewed)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewManga(atIndexPath: indexPath)
    }
}

// MARK: - ScrollView Mechanism
extension MDMangaDetailViewController: UIScrollViewDelegate {
    
    private var parentMaxContentOffsetY: CGFloat {
        lblDescr.frame.origin.y + lblDescr.frame.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        if isScrollingUp {
            if vScroll.contentOffset.y >= parentMaxContentOffsetY {
                vScroll.contentOffset.y = parentMaxContentOffsetY
            } else {
                vChapters.contentOffset.y = 0
            }
        } else {
            if vChapters.contentOffset.y > 0 {
                vScroll.contentOffset.y = parentMaxContentOffsetY
            }
        }
    }
}
