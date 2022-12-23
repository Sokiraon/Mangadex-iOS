//
//  MDMangaDetailHeaderView.swift
//  Mangadex
//
//  Created by John Rion on 12/17/22.
//

import Foundation
import UIKit
import TTTAttributedLabel
import SnapKit
import SafariServices
import PromiseKit

class MDMangaDetailHeaderView: UIView {
    private let ivCover = UIImageView(imageNamed: "manga_cover_default")
    private let lblTitle = UILabel(
        fontSize: 18,
        fontWeight: .medium,
        numberOfLines: 2
    )
    private let ivAuthor = UIImageView(imageNamed: "icon_person", color: .black2D2E2F)
    private let btnAuthor = UIButton(type: .system).apply { button in
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.theme_setTitleColor(UIColor.themeDarkPicker, forState: .normal)
    }
    private let lblAbout = UILabel(fontWeight: .medium)
    
    private var mangaModel: MDMangaItemDataModel!
    
    private var btnFollow: UIButton!
    private lazy var btnFollowConfFollowed = {
        var conf = UIButton.Configuration.tinted()
        
        conf.buttonSize = .small
        conf.cornerStyle = .capsule
        conf.imagePadding = 4
        conf.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        conf.image = .init(named: "icon_favorite")
        conf.baseForegroundColor = .primaryText
        conf.baseBackgroundColor = .themeLight
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .medium)
        conf.attributedTitle = AttributedString(
            "kMangaActionFollowed".localized(), attributes: container
        )
        
        return conf
    }()
    private lazy var btnFollowConfUnFollowed = {
        var conf = UIButton.Configuration.filled()
        
        conf.buttonSize = .small
        conf.cornerStyle = .capsule
        conf.imagePadding = 4
        conf.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        conf.image = .init(named: "icon_favorite_border")
        conf.baseBackgroundColor = .themePrimary
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .medium)
        conf.attributedTitle = AttributedString(
            "kMangaActionToFollow".localized(), attributes: container
        )
        
        return conf
    }()
    
    convenience init(mangaModel: MDMangaItemDataModel) {
        self.init()
        
        self.mangaModel = mangaModel
        self.setupUI()
    }
    
    private func setupUI() {
        addSubview(ivCover)
        ivCover.contentMode = .scaleAspectFill
        ivCover.layer.masksToBounds = true
        ivCover.layer.cornerRadius = 8
        ivCover.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.width.equalTo(100)
            make.height.equalTo(150)
        }
        if let coverArt = mangaModel.coverArts.first {
            let urlStr = "\(HostUrl.uploads.rawValue)/covers/\(mangaModel.id!)/\(coverArt.fileName!).256.jpg"
            ivCover.kf.setImage(with: URL(string: urlStr))
        }
        
        addSubview(lblTitle)
        lblTitle.text = mangaModel.attributes.localizedTitle
        lblTitle.snp.makeConstraints { make in
            make.top.equalTo(ivCover).inset(4)
            make.left.equalTo(ivCover.snp.right).offset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        addSubview(ivAuthor)
        ivAuthor.snp.makeConstraints { make in
            make.top.equalTo(lblTitle.snp.bottom).offset(12)
            make.left.equalTo(lblTitle)
            make.width.height.equalTo(18)
        }
        
        addSubview(btnAuthor)
        if let authorName = mangaModel.authors.first?.attributes.name {
            btnAuthor.setTitle(authorName, for: .normal)
        }
        btnAuthor.snp.makeConstraints { make in
            make.centerY.equalTo(ivAuthor)
            make.left.equalTo(ivAuthor.snp.right).offset(4)
        }
        
        addSubview(lblAbout)
        lblAbout.text = "kMangaDetailDescr".localized()
        lblAbout.snp.makeConstraints { make in
            make.top.equalTo(ivCover.snp.bottom).offset(16)
            make.left.equalTo(ivCover)
            make.bottom.equalToSuperview()
        }
        
        btnFollow = UIButton(
            configuration: btnFollowConfUnFollowed,
            primaryAction: UIAction { _ in
                self.changeFollowStatus()
            }
        )
        btnFollow.configurationUpdateHandler = { button in
            var newConfig: UIButton.Configuration!
            
            if self.isLoading {
                newConfig = button.configuration
                newConfig.showsActivityIndicator = true
            } else if self.readingStatus == .reading {
                newConfig = self.btnFollowConfFollowed
            } else {
                newConfig = self.btnFollowConfUnFollowed
            }
            
            button.configuration = newConfig
        }
        
        addSubview(btnFollow)
        btnFollow.snp.makeConstraints { make in
            make.left.equalTo(lblTitle)
            make.bottom.equalTo(ivCover).inset(4)
        }
    }
    
    private var readingStatus: MDMangaReadingStatus!
    private var isLoading = false
    
    func update(readingStatus: MDMangaReadingStatus) {
        self.readingStatus = readingStatus
        btnFollow.setNeedsUpdateConfiguration()
    }
    
    func changeFollowStatus() {
        isLoading = true
        btnFollow.setNeedsUpdateConfiguration()
        
        var promise: Promise<Bool>
        var newStatus: MDMangaReadingStatus
        if readingStatus == .reading {
            promise = MDRequests.Manga.unFollow(mangaId: mangaModel.id)
            newStatus = .null
        } else {
            promise = MDRequests.Manga.follow(mangaId: mangaModel.id)
            newStatus = .reading
        }
        _ = promise.done { result in
            self.isLoading = false
            self.readingStatus = newStatus
            self.btnFollow.setNeedsUpdateConfiguration()
        }
    }
}
