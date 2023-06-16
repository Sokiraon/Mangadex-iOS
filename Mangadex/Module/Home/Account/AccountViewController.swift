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
    private lazy var lblUsername = UILabel(fontSize: 20, fontWeight: .semibold, color: .white, numberOfLines: 2, scalable: true)
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
    
    private lazy var cellColorPicker = AccountSettingsPickerCell(identifier: "colorPicker").apply { cell in
        cell.icon = .init(named: "icon_palette")
        cell.title = "kSettingsThemeColor".localized()
        cell.delegate = self
    }
    
    private lazy var cellLangChoice = AccountSettingsMultiChoiceCell().apply { cell in
        cell.icon = .init(named: "icon_language")
        cell.title = "kSettingsChapterLanguage".localized()
        cell.popUpTitle = "settings.chapterLanguage.popUp.title".localized()
        cell.keys = MDLocale.availableLanguages
        cell.selectedKeysProvider = { Set(MDLocale.chapterLanguages) }
        cell.choiceItemUpdater = { choiceCell, indexPath, key in
            var content = choiceCell.defaultContentConfiguration()
            content.image = Flag(countryCode: MDLocale.languageToCountryCode[key]!)!.originalImage
            content.text = MDLocale.languageToName[key]
            choiceCell.contentConfiguration = content
        }
        cell.onSubmit = { selectedKeys in
            SettingsManager.chapterLanguages = Array(selectedKeys)
        }
    }
    
    private lazy var cellDownloads = AccountSettingsPushCell(identifier: "downloads").apply { cell in
        cell.icon = .init(named: "icon_download")
        cell.title = "kSettingsDownloads".localized()
        cell.delegate = self
    }
    
    private lazy var cellDeleteDownloads = AccountSettingsActionCell(identifier: "deleteDownloads").apply { cell in
        cell.icon = .init(named: "icon_delete")
        cell.title = "kSettingsDeleteDownloads".localized()
        cell.delegate = self
    }
    
    private lazy var settingsView = AccountSettingsView(
        sections: .init(cells: cellDataSaving),
            .init(cells: cellDownloads, cellColorPicker, cellLangChoice),
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
        ProgressHUD.show()
        DownloadsManager.default.deleteAllChapters()
        ProgressHUD.showSuccess()
        updateDownloadsSize()
    }
    
    private func updateDownloadsSize() {
        if let downloadsSize = DownloadsManager.default.sizeUsed {
            // The smallest value required to be shown as "1 MB"
            if downloadsSize < 950000 {
                cellDeleteDownloads.isEnabled = false
            } else {
                cellDeleteDownloads.isEnabled = true
            }
            cellDeleteDownloads.subTitle = "kSettingsCurrentDownloadsSize".localizedFormat(
                fileSizeFormatter.string(fromByteCount: Int64(downloadsSize))
            )
        }
    }
}

extension AccountViewController: AccountSettingsCellDelegate {
    func didSelectCell(_ cell: AccountSettingsCell, with identifier: String) {
        switch identifier {
        case "deleteDownloads":
            let vc = UIAlertController(
                title: "kWarning".localized(),
                message: "kSettingsDeleteDownloadsAlertMessage".localized(),
                preferredStyle: .alert
            )
            vc.addAction(UIAlertAction(title: "kCancel".localized(), style: .cancel))
            vc.addAction(UIAlertAction(title: "kOk".localized(), style: .destructive, handler: { _ in
                self.deleteDownloads()
            }))
            present(vc, animated: true)
            break
        default:
            break
        }
    }
    
    func viewControllerToPush(for cell: AccountSettingsCell, with identifier: String) -> UIViewController {
        switch identifier {
        case "downloads":
            return DownloadsViewController()
        default:
            return UIViewController()
        }
    }
    
    func viewToDisplay(for cell: AccountSettingsCell, with identifier: String) -> UIView {
        switch identifier {
        case "colorPicker":
            return AccountSettingsColorPickerView()
        default:
            return UIView()
        }
    }
}
