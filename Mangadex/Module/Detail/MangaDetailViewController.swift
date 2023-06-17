//
//  MangaDetailViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/1.
//

import Foundation
import UIKit
import SwiftTheme
import PromiseKit
import ProgressHUD
import SnapKit
import MJRefresh
import TTTAttributedLabel
import SafariServices
import MarkdownKit

/// Define a custom collectionView here to allow it to scroll with another scrollView.
private class MyCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

class MangaDetailViewController: BaseViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate {
    
    private var mangaModel: MangaModel!
    
    private lazy var refreshHeader = MJRefreshNormalHeader {
        self.fetchData()
    }
    private let vScroll = UIScrollView()
    
    private lazy var vHeader = MangaDetailHeaderView(mangaModel: mangaModel)
    private let lblDescr = TTTAttributedLabel()
    
    private let vDivider = LineView()
    private let vDivider2 = LineView()
    
    private let lblChapters = UILabel(fontSize: 18, fontWeight: .medium)
    private let vChaptersHeader = UIView()
    private var vChapters: MyCollectionView!
    
    private var chapterModels = [ChapterModel]()
    private var totalChapters = 0
    
    // MARK: - Lifecycle
    convenience init(mangaModel: MangaModel) {
        self.init()
        self.mangaModel = mangaModel
    }
    
    override func setupUI() {
        setupNavBar(title: mangaModel.attributes.localizedTitle)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        vScroll.delegate = self
        vScroll.delaysContentTouches = false
        vScroll.showsVerticalScrollIndicator = false
        vScroll.contentInsetAdjustmentBehavior = .never
        vScroll.mj_header = refreshHeader
        
        view.addSubview(vScroll)
        vScroll.snp.makeConstraints { make in
            make.top.equalTo(appBar.snp.bottom)
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
        parser.link.color = .themeDark
        let descrStr = NSMutableAttributedString(
            attributedString: parser.parse(mangaModel.attributes.localizedDescription)
        )
        let fontToUse = UIFont.systemFont(ofSize: 15)
        descrStr.addAttributes(
            [.font: fontToUse],
            range: .init(location: 0, length: descrStr.length)
        )
        lblDescr.delegate = self
        lblDescr.text = descrStr
        lblDescr.contentMode = .top
        
        let labelWidth = MDLayout.screenWidth - 16 * 2
        let constrainedSize = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        let rect = descrStr.boundingRect(
            with: constrainedSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let lines = rect.height / fontToUse.lineHeight
        if lines > 3 {
            lblDescr.numberOfLines = 0
            
            descrMinHeight = 3 * fontToUse.lineHeight
            
            descrExpandDuration = 0.2 + Double(lines - 4) * 0.02
            descrExpandDuration = min(descrExpandDuration, 0.4)
            
            lblDescr.snp.makeConstraints { make in
                make.height.equalTo(descrMinHeight)
            }
            
            vScroll.addSubview(btnDescrAction)
            btnDescrAction.setNeedsUpdateConfiguration()
            btnDescrAction.snp.makeConstraints { make in
                make.top.equalTo(lblDescr.snp.bottom)
                make.left.right.equalToSuperview().inset(16)
            }
            
            vScroll.addSubview(btnContinue)
            btnContinue.snp.makeConstraints { make in
                make.top.equalTo(btnDescrAction.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(44)
            }
        } else {
            lblDescr.numberOfLines = 3
            
            vScroll.addSubview(btnContinue)
            btnContinue.snp.makeConstraints { make in
                make.top.equalTo(lblDescr.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(44)
            }
        }
        
        vScroll.addSubview(vChaptersHeader)
        vChaptersHeader.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(btnContinue.snp.bottom).offset(16)
        }
        
        vChaptersHeader.addSubview(vDivider)
        vDivider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(0.67)
            make.left.right.equalToSuperview().inset(16)
        }
        
        vChaptersHeader.addSubview(lblChapters)
        lblChapters.text = "kMangaDetailChapters".localized()
        lblChapters.snp.makeConstraints { make in
            make.top.equalTo(vDivider.snp.bottom).offset(16)
            make.left.equalToSuperview().inset(16)
        }
        
        vChaptersHeader.addSubview(btnOrder)
        btnOrder.snp.makeConstraints { make in
            make.centerY.equalTo(lblChapters)
            make.right.equalToSuperview().inset(16)
        }
        
        vChaptersHeader.addSubview(vDivider2)
        vDivider2.snp.makeConstraints { make in
            make.top.equalTo(lblChapters.snp.bottom).offset(16)
            make.height.equalTo(0.67)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
        view.layoutIfNeeded()
        
        let collectionViewHeight = MDLayout.screenHeight - (
            appBar.frame.height + 16 + btnContinue.frame.height + 16 + vChaptersHeader.frame.height
        )
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        vChapters = MyCollectionView(
            frame: .zero, collectionViewLayout: collectionViewLayout
        )
        vChapters.bounces = false
        vChapters.delegate = self
        vChapters.dataSource = self
        vChapters.showsVerticalScrollIndicator = false
        
        vChapters.contentInset = .cssStyle(0, 16, MDLayout.adjustedSafeInsetBottom)
        vChapters.register(
            MangaChapterCollectionCell.self, forCellWithReuseIdentifier: "chapter"
        )
        vChapters.register(
            MDCollectionLoaderCell.self, forCellWithReuseIdentifier: "loader"
        )
        
        vScroll.addSubview(vChapters)
        vChapters.snp.makeConstraints { make in
            make.top.equalTo(vChaptersHeader.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(collectionViewHeight)
        }
    }
    
    override func didSetupUI() {
        vScroll.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveMangaProgress()
    }
    
    // MARK: - Expand Description
    
    private lazy var btnDescrActionConfUpdateHandler: UIButton.ConfigurationUpdateHandler = { button in
        var newConfig = button.configuration!
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14)
        if self.isExpanded {
            newConfig.image = .init(named: "icon_expand_less")
            newConfig.attributedTitle = AttributedString(
                "kMangaDetailDescrLess".localized(), attributes: container
            )
        } else {
            newConfig.image = .init(named: "icon_expand_more")
            newConfig.attributedTitle = AttributedString(
                "kMangaDetailDescrMore".localized(), attributes: container
            )
        }
        button.configuration = newConfig
    }
    
    private lazy var btnDescrActionConf = {
        var conf = UIButton.Configuration.plain()
        conf.buttonSize = .small
        conf.image = .init(named: "icon_expand_more")
        conf.imagePadding = 4
        conf.baseForegroundColor = .primaryText
        return conf
    }()
    
    private lazy var btnDescrAction = UIButton(
        configuration: btnDescrActionConf,
        primaryAction: UIAction { _ in self.expandFoldDescription() }
    ).apply { button in
        button.configurationUpdateHandler = self.btnDescrActionConfUpdateHandler
    }
    
    private var isExpanded = false
    
    private var descrMinHeight: CGFloat!
    private var descrExpandDuration: TimeInterval!
    
    private func expandFoldDescription() {
        if isExpanded {
            lblDescr.snp.remakeConstraints { make in
                make.top.equalTo(vHeader.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(self.descrMinHeight)
            }
        } else {
            lblDescr.snp.remakeConstraints { make in
                make.top.equalTo(vHeader.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(16)
            }
        }
        isExpanded = !isExpanded
        btnDescrAction.setNeedsUpdateConfiguration()
        UIView.animate(withDuration: descrExpandDuration) {
            self.vScroll.layoutIfNeeded()
        }
    }
    
    // MARK: - Button Continue
    
    private var lastViewedChapterId: String?
    
    private lazy var btnContinue = UIButton(
        type: .system,
        primaryAction: UIAction { _ in
            self.viewChapter(id: self.lastViewedChapterId)
        }
    ).apply { button in
        button.layer.cornerRadius = 22
        button.theme_backgroundColor = UIColor.themePrimaryPicker
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("kMangaActionStartOver".localized(), for: .normal)
    }
    
    private func retrieveMangaProgress() {
        lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: mangaModel.id)
        if lastViewedChapterId != nil {
            btnContinue.setTitle("kMangaActionContinue".localized(), for: .normal)
        }
    }
    
    // MARK: - Fetch Data
    
    private var chapterOrder = Requests.Chapter.Order.desc
    
    private lazy var btnOrder: UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.contentInsets = .zero
        conf.imagePlacement = .trailing
        conf.baseForegroundColor = .primaryText
        
        let button = UIButton(
            configuration: conf,
            primaryAction: UIAction { _ in
                self.updateChapterOrder()
            }
        )
        button.configurationUpdateHandler = { button in
            var conf = button.configuration
            let imageSize = CGSize(width: 20, height: 20)
            if self.chapterOrder == .asc {
                conf?.title = "Ascending".localized()
                conf?.image = .init(named: "icon_arrow_upward")?.resized(imageSize)
            } else {
                conf?.title = "Descending".localized()
                conf?.image = .init(named: "icon_arrow_downward")?.resized(imageSize)
            }
            button.configuration = conf
        }
        return button
    }()
    
    private func updateChapterOrder() {
        if chapterOrder == .desc {
            chapterOrder = .asc
        } else {
            chapterOrder = .desc
        }
        btnOrder.setNeedsUpdateConfiguration()
        vScroll.mj_header?.beginRefreshing()
    }
    
    private func fetchData() {
        _ = firstly {
            when(fulfilled: Requests.Manga.getReadingStatus(mangaId: mangaModel.id),
                 Requests.Chapter.getListForManga(
                     mangaId: mangaModel.id,
                     offset: 0,
                     order: chapterOrder
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
            // If found no chapters, do not allow user to click the view button.
            if self.chapterModels.isEmpty {
                self.btnContinue.isUserInteractionEnabled = false
            }
            DispatchQueue.main.async {
                self.vScroll.mj_header?.endRefreshing()
            }
        }
    }
    
    private func loadMoreChapters() {
        _ = firstly {
            Requests.Chapter.getListForManga(
                mangaId: mangaModel.id,
                offset: chapterModels.count,
                order: chapterOrder
            )
        }.done { result in
            self.chapterModels.append(contentsOf: result.data)
            self.totalChapters = result.total
            
            DispatchQueue.main.async {
                self.vChapters.reloadData()
            }
        }
    }
    
    private func viewChapter(id: String?) {
        let chapterId = id ?? chapterModels[0].id!
        let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true)
    }
    
    // MARK: - Double ScrollView Mechanism
    private var parentScrollViewMaxContentOffsetY: CGFloat {
        btnContinue.frame.origin.y - 16
    }
    
    private var hasParentScrollViewReachedMax = false
    private var isChildScrollViewScrollable: Bool {
        vChapters.contentSize.height > vChapters.frame.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isChildScrollViewScrollable else {
            return
        }
        if hasParentScrollViewReachedMax && (
            vChapters.contentOffset.y > 0 ||
            vScroll.contentOffset.y >= parentScrollViewMaxContentOffsetY
        ) {
            vScroll.contentOffset.y = parentScrollViewMaxContentOffsetY
            return
        }
        if vScroll.contentOffset.y >= parentScrollViewMaxContentOffsetY {
            // Set the flag
            hasParentScrollViewReachedMax = true
        } else {
            // Child scrollView is not allowed to scroll,
            // if parent scrollView hasn't reached the desired place.
            hasParentScrollViewReachedMax = false
            vChapters.contentOffset.y = 0
        }
    }
}

// MARK: - CollectionViewDelegate
extension MangaDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum CollectionSection: Int {
        case chapterList
        case loader
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = CollectionSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .chapterList:
            return chapterModels.count
        case .loader:
            return chapterModels.count < totalChapters ? 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch section {
        case .chapterList:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "chapter",
                for: indexPath
            ) as! MangaChapterCollectionCell
            
            let model = chapterModels[indexPath.row]
            cell.chapterView.setContent(with: model)
            return cell
            
        case .loader:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "loader",
                for: indexPath
            )
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return
        }
        guard !chapterModels.isEmpty else { return }
        
        if section == .loader {
            loadMoreChapters()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return
        }
        if section == .chapterList {
            let chapterInfo = chapterModels[indexPath.row]
            if let externalUrl = chapterInfo.attributes.externalUrl,
               let url = URL(string: externalUrl) {
                // if points to an external url, open it in a safari controller
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true)
            } else {
                viewChapter(id: chapterInfo.id)
            }
        }
    }
}
