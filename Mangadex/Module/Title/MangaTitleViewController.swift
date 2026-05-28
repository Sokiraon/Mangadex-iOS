//
//  MangaTitleViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/26.
//

import Foundation
import UIKit
import SnapKit
import ProgressHUD
import Agrume
import SwiftEntryKit

class MangaTitleViewController: BaseViewController {
    private var mangaModel: MangaModel!

    private let navigationTitleLabel = UILabel(
        fontSize: 17,
        fontWeight: .medium,
        color: .black2D2E2F,
        alignment: .center
    )
    
    private let tabVC = MangaTitleTabViewController()
    private let scrollView = UIScrollView()
    private let backgroundView = UIImageView()
    
    private let coverImage = UIImageView()
    private let coverActionHelper = AgrumeCoverActionHelper()
    private var coverImageViewer: Agrume?
    
    private let titleLabel = UILabel(fontSize: 24, fontWeight: .medium, numberOfLines: 2)
    private var continueButton: UIButton!
    
    private var followButton: LoadableButton!
    private var rateButton: LoadableButton!
    private let rateView = MangaTitleRatingView()

    private enum TitleActionButtonStyle {
        case follow(isFollowing: Bool, title: String?)
        case rating(userRating: Int, title: String?)

        var isActive: Bool {
            switch self {
            case .follow(let isFollowing, _):
                return isFollowing
            case .rating(let userRating, _):
                return userRating > 0
            }
        }
    }
    
    convenience init(mangaModel: MangaModel) {
        self.init()
        self.mangaModel = mangaModel
    }
    
    private lazy var BackgroundViewHeight = AppBarHeight + 16 + 180 + 16
    
    override func setupUI() {
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.frame = .init(x: 0, y: 0,
                                 width: MDLayout.screenWidth, height: MDLayout.screenHeight)
        
        scrollView.addSubview(backgroundView)
        backgroundView.alpha = 0.3
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.kf.setImage(with: mangaModel.coverURLOriginal,
                                   options: [.transition(.fade(0.2))])
        backgroundView.frame = .init(x: 0, y: 0, width: MDLayout.screenWidth,
                                     height: BackgroundViewHeight)
        
        setupSystemNavigationBar()
        
        scrollView.addSubview(coverImage)
        coverImage.contentMode = .scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.layer.cornerRadius = 8
        coverImage.isUserInteractionEnabled = true
        coverImage.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(showImage)))
        coverImage.kf.setImage(with: mangaModel.coverURL)
        if let url = mangaModel.coverURLOriginal {
            coverImageViewer = Agrume(url: url)
            coverImageViewer?.onLongPress = coverActionHelper.makeLongPressHandler
        }
        
        coverImage.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(AppBarHeight + 16)
            make.left.equalToSuperview().inset(16)
            make.width.equalTo(120)
            make.height.equalTo(180)
        }
        
        scrollView.addSubview(titleLabel)
        titleLabel.text = mangaModel.attributes.localizedTitle
        titleLabel.layer.shadowOffset = .init(width: 1, height: 2)
        titleLabel.layer.shadowRadius = 2
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImage)
            make.left.equalTo(coverImage.snp.right).offset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        followButton = LoadableButton(
            configuration: makeTitleActionButtonConfiguration(
                for: .follow(
                    isFollowing: false,
                    title: followStatisticsText
                )
            ),
            primaryAction: UIAction { [weak self] _ in
                self?.changeFollowStatus()
            }
        )
        followButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = self.makeTitleActionButtonConfiguration(
                for: .follow(
                    isFollowing: self.isFollowing,
                    title: self.followStatisticsText
                )
            )
        }
        applyTitleActionButtonShadow(to: followButton)
        
        scrollView.addSubview(followButton)
        followButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(titleLabel)
        }
        
        rateButton = LoadableButton(
            configuration: makeTitleActionButtonConfiguration(
                for: .rating(
                    userRating: 0,
                    title: ratingStatisticsText
                )
            ),
            primaryAction: UIAction { [weak self] _ in
                self?.showRatingView()
            }
        )
        rateButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = self.makeTitleActionButtonConfiguration(
                for: .rating(
                    userRating: self.rating,
                    title: self.ratingStatisticsText
                )
            )
        }
        applyTitleActionButtonShadow(to: rateButton)
        
        scrollView.addSubview(rateButton)
        rateButton.snp.makeConstraints { make in
            make.top.equalTo(followButton)
            make.left.equalTo(followButton.snp.right).offset(8)
        }
        
        var continueConfig = UIButton.Configuration.filled()
        continueConfig.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        continueConfig.cornerStyle = .medium
        continueConfig.baseBackgroundColor = .themePrimary
        continueConfig.title = "kMangaActionStartOver".localized()
        continueButton = UIButton(configuration: continueConfig,
                                  primaryAction: UIAction { [unowned self] _ in self.startReading() })
        
        scrollView.addSubview(continueButton)
        continueButton.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(coverImage)
        }
        
        addChild(tabVC)
        tabVC.mangaModel = mangaModel
        let tabVCHeight = MDLayout.screenHeight - (MDLayout.safeInsetTop + 44)
        scrollView.addSubview(tabVC.view)
        tabVC.chaptersTab.collectionView.delegate = self
        tabVC.infoTab.collectionView.delegate = self
        tabVC.coversTab.collectionView.delegate = self
        tabVC.view.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
            make.height.equalTo(tabVCHeight)
        }
        
        rateView.onSubmit = { [unowned self] rating in
            updateRating(to: rating)
        }
    }

    private var isFollowing: Bool {
        readingStatus != nil
    }

    private var statistics: MangaStatisticsModel? {
        didSet {
            followButton?.setNeedsUpdateConfiguration()
            rateButton?.setNeedsUpdateConfiguration()
        }
    }

    private var followStatisticsText: String? {
        statistics?.followsString
    }

    private var ratingStatisticsText: String? {
        statistics?.ratingString
    }

    private func makeTitleActionButtonConfiguration(
        for style: TitleActionButtonStyle
    ) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .small
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .white
        config.baseForegroundColor = titleActionButtonForegroundColor(
            isActive: style.isActive
        )
        config.contentInsets = .cssStyle(8, 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 15, weight: .medium)
            return outgoing
        }

        switch style {
        case .follow(let isFollowing, let title):
            config.image = UIImage(
                named: isFollowing ? "icon_heart" : "icon_heart_border"
            )
            config.title = title
            config.imagePadding = title == nil ? 0 : 4

        case .rating(let userRating, let title):
            config.image = UIImage(
                named: userRating > 0 ? "icon_grade_filled" : "icon_grade"
            )
            config.title = title
            config.imagePadding = title == nil ? 0 : 4
        }

        return config
    }

    private func titleActionButtonForegroundColor(isActive: Bool) -> UIColor {
        isActive ? .themePrimary : .darkerGray565656
    }

    private func applyTitleActionButtonShadow(to button: LoadableButton) {
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 8
    }
    
    override func didSetupUI() {
        statistics = mangaModel.statistics
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        rateButton.isLoading = true
        followButton.isLoading = true
        let mangaId = mangaModel.id!
        do {
            async let ratingRequest = Requests.User.getMangaRating(for: mangaId)
            async let readingStatusRequest = Requests.Manga.getReadingStatus(mangaId: mangaId)
            async let statisticsRequest = fetchStatisticsIfNeeded(mangaId: mangaId)
            let (rating, readingStatus, statistics) = try await (
                ratingRequest,
                readingStatusRequest,
                statisticsRequest
            )
            self.rating = rating
            self.readingStatus = readingStatus
            self.statistics = statistics
        } catch {
            
        }
        rateButton.isLoading = false
        followButton.isLoading = false
    }

    private func fetchStatisticsIfNeeded(
        mangaId: String
    ) async -> MangaStatisticsModel? {
        if let statistics = mangaModel.statistics {
            return statistics
        }

        do {
            let statistics = try await Requests.Manga.getStatistics(mangaId: mangaId)
            mangaModel.statistics = statistics
            return statistics
        } catch {
            return nil
        }
    }
    
    var parentScrollViewHasReachedMax = false
    lazy var parentScrollViewMaxOffsetY = BackgroundViewHeight - AppBarHeight
    lazy var titleLabelScrollInOffsetY = titleLabel.frame.origin.y - AppBarHeight
    lazy var titleLabelScrollOutOffsetY = titleLabelScrollInOffsetY + titleLabel.frame.height
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSystemNavigationBar()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        updateNavigationBarAppearance()
        retrieveMangaProgress()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNavigationBarAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    var lastViewedChapterId: String?
    func startReading() {
        let chapterId = lastViewedChapterId ?? tabVC.chaptersTab.chapterModels.first?.id
        let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterId!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    var readingStatus: MangaReadingStatus? {
        didSet {
            followButton.setNeedsUpdateConfiguration()
            followButton.spinner.color = titleActionButtonForegroundColor(
                isActive: isFollowing
            )
        }
    }
    
    func changeFollowStatus() {
        let mangaId = mangaModel.id!
        Task {
            followButton.isLoading = true
            do {
                if !isFollowing {
                    _ = try await Requests.Manga.follow(mangaId: mangaId)
                    readingStatus = .reading
                } else {
                    _ = try await Requests.Manga.unFollow(mangaId: mangaId)
                    readingStatus = nil
                }
            } catch {
                ProgressHUD.failed()
            }
            followButton.isLoading = false
        }
    }
    
    func retrieveMangaProgress() {
        lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: mangaModel.id)
        if lastViewedChapterId != nil {
            continueButton.configuration?.title = "kMangaActionContinue".localized()
        }
    }
    
    @objc func showImage() {
        coverImageViewer?.show(from: self)
    }
    
    var rating = 0 {
        didSet {
            rateView.rating = rating
            rateButton.setNeedsUpdateConfiguration()
            rateButton.spinner.color = titleActionButtonForegroundColor(
                isActive: rating > 0
            )
        }
    }
    
    func updateRating(to value: Int) {
        rateButton.isLoading = true
        let mangaId = mangaModel.id!
        Task {
            _ = await Requests.User.setMangaRating(for: mangaId, to: value)
            self.rating = value
            self.rateButton.isLoading = false
        }
    }
    
    func showRatingView() {
        var attrs = EKAttributes.centerFloat
        attrs.name = "Rating Popup"
        attrs.displayDuration = .infinity
        attrs.screenInteraction = .dismiss
        attrs.entryInteraction = .forward
        attrs.screenBackground = .color(color: EKColor(UIColor(white: 0.5, alpha: 0.5)))
        attrs.positionConstraints.size = .init(
            width: .constant(value: MDLayout.screenWidth - 30), height: .intrinsic)
        attrs.entranceAnimation = .init(
            translate: .init(duration: 0.5, spring: .init(damping: 1, initialVelocity: 0)),
            scale: nil,
            fade: nil)
        SwiftEntryKit.display(entry: rateView, using: attrs)
    }
    
    func didTapDownload() {
        let vc = MangaDownloadViewController(mangaModel: mangaModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func setupSystemNavigationBar() {
        statusBarStyle = .darkContent
        navigationItem.largeTitleDisplayMode = .never

        navigationTitleLabel.text = mangaModel.attributes.localizedTitle
        navigationItem.titleView = navigationTitleLabel

        let downloadImage = UIImage(named: "icon_download")?
            .withRenderingMode(.alwaysTemplate)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: downloadImage,
            style: .plain,
            target: self,
            action: #selector(didTapDownloadButton)
        )

        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .black2D2E2F
        updateNavigationBarAppearance()
    }

    private func updateNavigationBarAppearance() {
        guard titleLabel.bounds.height > 0 else {
            applyNavigationBarAppearance(progress: 0)
            return
        }

        let parentOffsetY = scrollView.contentOffset.y
        var progress = (parentOffsetY - titleLabelScrollInOffsetY) / titleLabel.frame.height
        progress = max(progress, 0)
        progress = min(progress, 1)

        applyNavigationBarAppearance(progress: progress)
    }

    private func applyNavigationBarAppearance(progress: CGFloat) {
        navigationTitleLabel.alpha = progress

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = progress > 0
            ? UIBlurEffect(style: .systemUltraThinMaterialLight)
            : nil
        appearance.backgroundColor = UIColor.white.withAlphaComponent(progress * 0.88)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black2D2E2F,
            .font: UIFont.systemFont(ofSize: 17, weight: .medium)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    @objc private func didTapDownloadButton() {
        didTapDownload()
    }
}

extension MangaTitleViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let parentOffsetY = self.scrollView.contentOffset.y
        if parentScrollViewHasReachedMax && (
            tabVC.currentScrollView.contentOffset.y > -8 ||
            parentOffsetY >= parentScrollViewMaxOffsetY
        ) {
            self.scrollView.contentOffset.y = parentScrollViewMaxOffsetY
            return
        }
        if parentOffsetY >= parentScrollViewMaxOffsetY {
            parentScrollViewHasReachedMax = true
        } else {
            parentScrollViewHasReachedMax = false
            tabVC.currentScrollView.contentOffset.y = -8
        }
        if parentOffsetY < 0 {
            backgroundView.frame = .init(x: 0, y: parentOffsetY,
                                         width: MDLayout.screenWidth,
                                         height: BackgroundViewHeight - parentOffsetY)
        }
        updateNavigationBarAppearance()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if collectionView == tabVC.chaptersTab.collectionView,
           cell is CollectionLoaderCell {
            tabVC.chaptersTab.loadMoreChapters()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == tabVC.chaptersTab.collectionView,
           indexPath.section == 0 {
            tabVC.chaptersTab.viewChapter(at: indexPath)
        }
    }
}
