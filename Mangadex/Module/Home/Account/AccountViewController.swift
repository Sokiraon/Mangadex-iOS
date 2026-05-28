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
    
    private lazy var vTopArea = CardView().apply { view in
        view.cornerRadius = 16
        view.shadowCornerRadius = 16
    }
    private lazy var ivAvatar = UIImageView(named: "icon_avatar_round")
    private lazy var lblUsername = UILabel(fontSize: 20, fontWeight: .semibold, color: .primaryText,
                                           numberOfLines: 2, scalable: true)
    private lazy var vAccountAction = UIStackView().apply { stack in
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
    }
    private lazy var btnLogin = UIButton(
        configuration: loginButtonConfiguration,
        primaryAction: UIAction { [weak self] _ in
            self?.didTapLogin()
        }
    ).apply { button in
        button.isHidden = true
    }
    private lazy var btnLogout = UIButton(
        configuration: logoutButtonConfiguration,
        primaryAction: UIAction { [weak self] _ in
            self?.didTapLogout()
        }
    ).apply { button in
        button.isHidden = true
    }

    private var loginButtonConfiguration: UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = "kLoginUser".localized()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .themePrimary
        config.cornerStyle = .capsule
        config.contentInsets = .cssStyle(8, 14)
        return config
    }

    private var logoutButtonConfiguration: UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "icon_logout")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.title = "kLogout".localized()
        config.baseForegroundColor = .themeDark
        config.baseBackgroundColor = .themeLightest
        config.cornerStyle = .capsule
        config.contentInsets = .cssStyle(8, 14)
        return config
    }
    
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
    
    private lazy var cellHistory = AccountSettingsPushCell().apply { cell in
        cell.icon = .init(named: "icon_history")
        cell.title = String(localized: "Reading History")
        cell.viewControllerClass = ReadingHistoryViewController.self
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
        sections: .init(
            cells: cellHistory,
            cellDownloading,
            cellDownloads
        ),
        .init(
            cells: cellDataSaving,
            cellColorSelector,
            cellLangSelector,
            cellContentSelector
        ),
        .init(cells: cellDeleteDownloads)
    )
    
    override func setupUI() {
        view.backgroundColor = .lightestGrayF5F5F5
        
        view.addSubview(vTopArea)
        vTopArea.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        vTopArea.addSubview(ivAvatar)
        ivAvatar.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.top.bottom.equalToSuperview().inset(20)
            make.left.equalToSuperview().inset(20)
        }
        
        vTopArea.addSubview(vAccountAction)
        vAccountAction.snp.makeConstraints { make in
            make.centerY.equalTo(ivAvatar)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

        vAccountAction.addArrangedSubview(btnLogin)
        vAccountAction.addArrangedSubview(btnLogout)
        
        vTopArea.addSubview(lblUsername)
        lblUsername.snp.makeConstraints { make in
            make.centerY.equalTo(ivAvatar)
            make.left.equalTo(ivAvatar.snp.right).offset(20)
            make.right.equalTo(vAccountAction.snp.left).offset(-20)
        }
        lblUsername.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapUsername)))
        
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(vTopArea.snp.bottom).offset(16)
        }
    }
    
    override func didSetupUI() {
        syncUserManagerStates()
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
        syncUserManagerStates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await updateDownloadsSize()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    // MARK: - actions
    
    private func didTapLogout() {
        Task { @MainActor in
            await UserManager.shared.logout()
            MDRouter.goToLogin()
        }
    }

    private func didTapLogin() {
        MDRouter.goToLogin()
    }
    
    @objc private func didTapUsername() {
        Task { @MainActor in
            let isLoggedIn = await UserManager.shared.userIsLoggedIn
            if !isLoggedIn {
                MDRouter.goToLogin()
            }
        }
    }
    
    @objc private func didUpdateSetting() {}
    
    private func syncUserManagerStates() {
        Task { @MainActor in
            let isLoggedIn = await UserManager.shared.userIsLoggedIn
            let username = await UserManager.shared.username
            self.btnLogout.isHidden = !isLoggedIn
            self.btnLogin.isHidden = isLoggedIn
            self.lblUsername.text = username
            self.lblUsername.isUserInteractionEnabled = false
        }
    }
    
    @objc private func deleteDownloads() {
        ProgressHUD.animate()
        DownloadManager.shared.deleteAllChapters()
        ProgressHUD.succeed()
        
        Task {
            await updateDownloadsSize()
        }
    }
    
    private func updateDownloadsSize() async {
        cellDeleteDownloads.isEnabled = false
        guard let size = await DownloadManager.shared.calculateSizeUsed() else {
            return
        }
        
        await MainActor.run {
            // The smallest value required to be shown as "1 MB"
            if size < 950000 {
                cellDeleteDownloads.isEnabled = false
                cellDeleteDownloads.subTitle = "kSettingsDownloadsSizeZero"
                    .localized()
            } else {
                cellDeleteDownloads.isEnabled = true
                cellDeleteDownloads.subTitle = "kSettingsDownloadsSizeCurrent"
                    .localizedFormat(
                        fileSizeFormatter.string(
                            fromByteCount: Int64(size)
                        )
                    )
            }
        }
    }
}
