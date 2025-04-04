//
//  AccountViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/15.
//

import Foundation
import UIKit
import SwiftTheme
import SnapKit
import ProgressHUD
import FlagKit

class AccountViewController: BaseViewController {
    
    private lazy var vTopArea = UIView()
    private lazy var ivAvatar = UIImageView(named: "icon_avatar_round")
    private lazy var lblUsername = UILabel(fontSize: 20, fontWeight: .semibold, color: .white,
                                           numberOfLines: 2, scalable: true)
    private lazy var btnLogout: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_logout"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        button.isHidden = !UserManager.shared.userIsLoggedIn
        return button
    }()
    
    private lazy var cellDataSaving = AccountSettingsSwitchCell(key: .isDataSaving).apply { cell in
        cell.icon = .init(named: "icon_signal_cellular")
        cell.title = "kSettingsDataSaving".localized()
    }
    
    private lazy var cellColorSelector = AccountSettingsSelectorCell().apply { cell in
        cell.icon = .init(named: "icon_palette")
        cell.title = "kSettingsThemeColor".localized()
        cell.popupTitle = "settings.themeColor.popup.title".localized()
        cell.keys = UIColor.availableColors
        cell.selectedKeysProvider = { [UIColor.availableColors[ThemeManager.currentThemeIndex]] }
        cell.itemDecorator = { item, indexPath, key in
            let color = UIColor.primaryColors[UIColor.availableColors.firstIndex(of: key)!]
            var content = item.defaultContentConfiguration()
            content.text = key.localized()
            content.textProperties.color = color
            content.image = UIImage(named: "dot")
            content.imageProperties.tintColor = color
            item.contentConfiguration = content
        }
        cell.onSubmit = { selectedKeys in
            SettingsManager.themeColorIndex = UIColor.availableColors.firstIndex(of: selectedKeys[0])!
        }
    }
    
    private lazy var cellLangSelector = AccountSettingsSelectorCell().apply { cell in
        cell.icon = .init(named: "icon_language")
        cell.title = "kSettingsChapterLanguage".localized()
        cell.popupTitle = "settings.chapterLanguage.popup.title".localized()
        cell.keys = MDLocale.availableLanguages
        cell.selectedKeysProvider = { MDLocale.chapterLanguages }
        cell.allowMultiple = true
        cell.itemDecorator = { choiceCell, indexPath, key in
            var content = choiceCell.defaultContentConfiguration()
            content.image = Flag(countryCode: MDLocale.languageToCountryCode[key]!)!.originalImage
            let locale = Locale(identifier: key)
            content.text = locale.localizedString(forIdentifier: key)
            choiceCell.contentConfiguration = content
        }
        cell.onSubmit = { selectedKeys in
            SettingsManager.chapterLanguages = selectedKeys
        }
    }
    
    private lazy var cellContentSelector = AccountSettingsSelectorCell().apply { cell in
        cell.icon = .init(named: "icon_18_up")
        cell.title = "settings.contentFilter.title".localized()
        cell.popupTitle = "settings.contentFilter.popup.title".localized()
        cell.keys = SettingsManager.contentFilterOptions
        cell.selectedKeysProvider = { SettingsManager.contentFilter }
        cell.allowMultiple = true
        cell.itemDecorator = { choiceCell, indexPath, key in
            var content = choiceCell.defaultContentConfiguration()
            content.text = key.localized()
            choiceCell.contentConfiguration = content
        }
        cell.onSubmit = { selectedKeys in
            SettingsManager.contentFilter = selectedKeys
        }
    }
    
    private lazy var cellDownloading = AccountSettingsPushCell().apply { cell in
        cell.icon = .init(named: "icon_downloading")
        cell.title = "mypage.downloading.title".localized()
        cell.viewControllerClass = DownloadingViewController.self
    }
    
    private lazy var cellDownloads = AccountSettingsPushCell().apply { cell in
        cell.icon = .init(named: "icon_download")
        cell.title = "mypage.downloaded.title".localized()
        cell.viewControllerClass = DownloadsViewController.self
    }
    
    private lazy var cellDeleteDownloads = AccountSettingsActionCell().apply { cell in
        cell.icon = .init(named: "icon_delete")
        cell.title = "kSettingsDeleteDownloads".localized()
        cell.onSelect = {
            let vc = UIAlertController(
                title: "kWarning".localized(),
                message: "kSettingsDeleteDownloadsAlertMessage".localized(),
                preferredStyle: .alert
            )
            vc.addAction(UIAlertAction(title: "kCancel".localized(), style: .cancel))
            vc.addAction(UIAlertAction(title: "kOk".localized(), style: .destructive, handler: { _ in
                self.deleteDownloads()
            }))
            self.present(vc, animated: true)
        }
    }
    
    private lazy var settingsView = AccountSettingsView(
        sections:
                .init(cells: cellDataSaving),
                .init(cells: cellDownloading, cellDownloads, cellColorSelector, cellLangSelector, cellContentSelector),
                .init(cells: cellDeleteDownloads)
    )
    
    override func setupUI() {
        view.backgroundColor = .lightestGrayF5F5F5
        
        view.addSubview(vTopArea)
        vTopArea.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        vTopArea.theme_backgroundColor = UIColor.themePrimaryPicker
        
        vTopArea.addSubview(ivAvatar)
        ivAvatar.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop + 30)
            make.left.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(35)
        }
        
        vTopArea.addSubview(btnLogout)
        btnLogout.snp.makeConstraints { make in
            make.centerY.equalTo(ivAvatar)
            make.right.equalToSuperview().inset(55)
        }
        
        vTopArea.addSubview(lblUsername)
        lblUsername.snp.makeConstraints { make in
            make.centerY.equalTo(ivAvatar)
            make.left.equalTo(ivAvatar.snp.right).offset(20)
            make.right.equalTo(btnLogout.snp.left).offset(-20)
        }
        lblUsername.text = UserManager.shared.username
        lblUsername.isUserInteractionEnabled = !UserManager.shared.userIsLoggedIn
        lblUsername.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapUsername)))
        
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(vTopArea.snp.bottom).offset(15)
        }
    }
    
    override func didSetupUI() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateSetting),
            name: .MangadexDidChangeSettings,
            object: nil
        )
    }
    
    let fileSizeFormatter = ByteCountFormatter().apply { formatter in
        formatter.allowedUnits = [.useMB, .useGB]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDownloadsSize()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - actions
    
    @objc private func didTapLogout() {
        UserManager.logOutAsUser()
        MDRouter.goToLogin()
    }
    
    @objc private func didTapUsername() {
        if !UserManager.shared.userIsLoggedIn {
            MDRouter.goToLogin()
        }
    }
    
    @objc private func didUpdateSetting() {}
    
    @objc private func deleteDownloads() {
        ProgressHUD.animate()
        DownloadManager.shared.deleteAllChapters()
        ProgressHUD.succeed()
        updateDownloadsSize()
    }
    
    private func updateDownloadsSize() {
        if let downloadsSize = DownloadManager.shared.sizeUsed {
            // The smallest value required to be shown as "1 MB"
            if downloadsSize < 950000 {
                cellDeleteDownloads.isEnabled = false
                cellDeleteDownloads.subTitle = "kSettingsDownloadsSizeZero".localized()
            } else {
                cellDeleteDownloads.isEnabled = true
                cellDeleteDownloads.subTitle = "kSettingsDownloadsSizeCurrent".localizedFormat(
                    fileSizeFormatter.string(fromByteCount: Int64(downloadsSize))
                )
            }
        }
    }
}
