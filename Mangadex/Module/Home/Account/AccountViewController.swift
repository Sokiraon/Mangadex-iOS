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

class AccountViewController: BaseViewController {
    
    private lazy var vTopArea = UIView()
    private lazy var ivAvatar = UIImageView(imageNamed: "icon_avatar_round")
    private lazy var lblUsername = UILabel(fontSize: 20, fontWeight: .semibold, color: .white, numberOfLines: 2, scalable: true)
    private lazy var btnLogout: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_logout"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        button.isHidden = !UserManager.shared.userIsLoggedIn
        return button
    }()
    
    private lazy var cellDataSaving = AccountSettingsSwitchItem(
        icon: .init(named: "icon_signal_cellular"),
        title: "kSettingsDataSaving".localized(),
        key: .isDataSaving
    )
    
    private lazy var colorCell: MDAccountSettingsCell = {
        let cell = MDAccountSettingsCell(
            icon: .init(named: "icon_palette"), title: "kPrefThemeColor".localized()
        )
        cell.setActionType(.popUp, withId: "colorSelector")
        cell.delegate = self
        return cell
    }()
    private lazy var langCell: MDAccountSettingsCell = {
        let cell = MDAccountSettingsCell(
            icon: .init(named: "icon_language"),
            title: "kPrefMangaLang".localized(),
            subtitle: "kPrefMangaLangCur".localizedFormat(
                MDLocale.languages[SettingsManager.mangaLangIndex]
            )
        )
        cell.setActionType(.popUp, withId: "langSelector")
        cell.delegate = self
        return cell
    }()
    private lazy var downloadsCell = MDAccountSettingsCell(
        icon: .init(named: "icon_download"), title: "kPrefDownloads".localized()
    ).apply { cell in
        cell.setActionType(.newPage, withId: "downloads")
        cell.delegate = self
    }
    
    private lazy var configSection1 = AccountSettingsSection(cells: [cellDataSaving])
    private lazy var configSection2 = AccountSettingsSection(cells: [downloadsCell, colorCell, langCell])
    private lazy var vConfigStack = UIStackView(
        arrangedSubviews: [configSection1, configSection2]
    ).apply { vStack in
        vStack.axis = .vertical
        vStack.spacing = 16
    }
    
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
        
        view.addSubview(vConfigStack)
        vConfigStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(vTopArea.snp.bottom).offset(15)
        }
    }
    
    override func didSetupUI() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateSetting),
            name: NSNotification.Name(SettingsDidUpdateNotification),
            object: nil
        )
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
    
    @objc private func didUpdateSetting() {
        langCell.lblSubtitle.text = "kPrefMangaLangCur".localizedFormat(
            MDLocale.languages[SettingsManager.mangaLangIndex]
        )
    }
}

extension AccountViewController: MDAccountSettingsCellDelegate {
    func viewControllerToDisplay(forCell cell: MDAccountSettingsCell, withId id: String) -> UIViewController? {
        switch id {
        case "downloads":
            return DownloadsViewController()
        default:
            return nil
        }
    }
    
    func viewToDisplay(forCell cell: MDAccountSettingsCell, withId id: String) -> MDSettingsPopupView? {
        switch id {
        case "colorSelector":
            return MDColorSettingsPopupView()
        case "langSelector":
            return MDLangSettingsPopupView()
        default:
            return nil
        }
    }
}
