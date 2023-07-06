//
//  MangaTitleViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/26.
//

import Foundation
import UIKit
import SnapKit
import PromiseKit
import ProgressHUD
import Agrume
import SwiftEntryKit

class MangaTitleViewController: BaseViewController {
    private var mangaModel: MangaModel!
    
    private let tabVC = MangaTitleTabViewController()
    private let scrollView = UIScrollView()
    private let backgroundView = UIImageView()
    
    private let coverImage = UIImageView()
    private var coverImageViewer: Agrume?
    
    private let titleLabel = UILabel(fontSize: 24, fontWeight: .medium, numberOfLines: 2)
    private var continueButton: UIButton!
    
    private var followButton: LoadableButton!
    private lazy var followButtonConfigDefault: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.image = .init(named: "icon_heart_border")
        config.baseBackgroundColor = .lightestGrayF5F5F5
        config.baseForegroundColor = .darkerGray565656
        return config
    }()
    private lazy var followButtonConfigActive: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.image = .init(named: "icon_heart")
        config.baseBackgroundColor = .themePrimary
        config.baseForegroundColor = .white
        return config
    }()
    
    private var rateButton: LoadableButton!
    private lazy var rateButtonConfigDefault: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.image = .init(named: "icon_grade")
        config.baseBackgroundColor = .lightestGrayF5F5F5
        config.baseForegroundColor = .darkerGray565656
        return config
    }()
    private lazy var rateButtonConfigActive: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.image = .init(named: "icon_grade_filled")
        config.imagePadding = 4
        config.baseBackgroundColor = .themePrimary
        config.baseForegroundColor = .white
        return config
    }()
    private let rateView = MangaTitleRatingView()
    
    convenience init(mangaModel: MangaModel) {
        self.init()
        self.mangaModel = mangaModel
    }
    
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
        backgroundView.frame = .init(x: 0, y: 0, width: MDLayout.screenWidth, height: 303)
        
        setupNavBar(title: mangaModel.attributes.localizedTitle, style: .blur)
        appBar.blurView.alpha = 0
        appBar.lblTitle.alpha = 0
        
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
        }
        
        coverImage.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(appBarHeight + 16)
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
        
        followButton = LoadableButton(configuration: followButtonConfigDefault,
                                      primaryAction: UIAction { _ in self.changeFollowStatus() })
        followButton.configurationUpdateHandler = { button in
            if self.readingStatus == .null {
                button.configuration = self.followButtonConfigDefault
            } else {
                button.configuration = self.followButtonConfigActive
            }
        }
        
        scrollView.addSubview(followButton)
        followButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(titleLabel)
        }
        
        rateButton = LoadableButton(configuration: rateButtonConfigDefault,
                                    primaryAction: UIAction { _ in self.showRatingView() })
        rateButton.configurationUpdateHandler = { button in
            if self.rating == 0 {
                button.configuration = self.rateButtonConfigDefault
            } else {
                button.configuration = self.rateButtonConfigActive
                button.configuration?.title = String(self.rating)
            }
        }
        
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
                                  primaryAction: UIAction { _ in self.startReading() })
        
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
        tabVC.infoTab.scrollView.delegate = self
        tabVC.coversTab.collectionView.delegate = self
        tabVC.view.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
            make.height.equalTo(tabVCHeight)
        }
        
        fetchData()
    }
    
    func fetchData() {
        followButton.isLoading = true
        _ = Requests.Manga.getReadingStatus(mangaId: mangaModel.id)
            .done { status in
                self.readingStatus = status
            }
            .ensure {
                self.followButton.isLoading = false
            }
        rateButton.isLoading = true
        _ = Requests.User.getMangaRating(for: mangaModel.id)
            .done { rating in
                self.rating = rating
            }
            .ensure {
                self.rateButton.isLoading = false
                self.rateView.onSubmit = { rating in
                    self.updateRating(to: rating)
                }
            }
    }
    
    var parentScrollViewHasReachedMax = false
    let parentScrollViewMaxOffsetY = 303.0 - (MDLayout.safeInsetTop + 44)
    lazy var titleLabelScrollInOffsetY: CGFloat = {
        titleLabel.frame.origin.y - (MDLayout.safeInsetTop + 44)
    }()
    lazy var titleLabelScrollOutOffsetY: CGFloat = {
        titleLabelScrollInOffsetY + titleLabel.frame.height
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveMangaProgress()
    }
    
    var lastViewedChapterId: String?
    func startReading() {
        let chapterId = lastViewedChapterId ?? tabVC.chaptersTab.chapterModels.first?.id
        let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterId!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    var readingStatus: MangaReadingStatus = .null {
        didSet {
            followButton.setNeedsUpdateConfiguration()
            if readingStatus == .null {
                followButton.spinner.color = .darkerGray565656
            } else {
                followButton.spinner.color = .white
            }
        }
    }
    func changeFollowStatus() {
        var newStatus: MangaReadingStatus
        var request: Promise<Bool>
        if readingStatus == .null {
            newStatus = .reading
            request = Requests.Manga.follow(mangaId: mangaModel.id)
        } else {
            newStatus = .null
            request = Requests.Manga.unFollow(mangaId: mangaModel.id)
        }
        followButton.isLoading = true
        request.done { success in
            self.readingStatus = newStatus
        }.catch { error in
            ProgressHUD.showError()
        }.finally {
            self.followButton.isLoading = false
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
            if rating == 0 {
                rateButton.spinner.color = .darkerGray565656
            } else {
                rateButton.spinner.color = .white
            }
        }
    }
    
    func updateRating(to value: Int) {
        rateButton.isLoading = true
        _ = Requests.User.setMangaRating(for: mangaModel.id, to: value)
            .done { success in
                self.rating = value
            }
            .ensure {
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
                                         height: 303 - parentOffsetY)
        }
        var delta = (parentOffsetY - titleLabelScrollInOffsetY) / titleLabel.frame.height
        delta = max(delta, 0)
        delta = min(delta, 1)
        appBar.blurView.alpha = delta
        if delta == 1 {
            UIView.animate(withDuration: 0.2) {
                self.appBar.lblTitle.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.appBar.lblTitle.alpha = 0
            }
        }
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
