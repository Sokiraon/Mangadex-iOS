//
//  MDAccountViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/15.
//

import Foundation
import UIKit
import SwiftTheme

class MDAccountViewController: MDViewController {
    
    private lazy var vTopArea = UIView()
    private lazy var ivAvatar = UIImageView(imageNamed: "icon_avatar_round")
    private lazy var lblUsername = UILabel(fontSize: 20, fontWeight: .semibold, color: .white, numberOfLines: 2, scalable: true)
    private lazy var btnLogout: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_logout"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        button.isHidden = !MDUserManager.getInstance().isLoggedIn()
        return button
    }()
    
    private lazy var colorCell: MDAccountSettingsCell = {
        let cell = MDAccountSettingsCell(
            textStyle: .oneLine, iconName: "icon_palette", title: "kPrefThemeColor".localized()
        )
        cell.setActionType(.selector, withId: "colorSelector")
        cell.delegate = self
        return cell
    }()
    private lazy var langCell: MDAccountSettingsCell = {
        let cell = MDAccountSettingsCell(
            textStyle: .twoLine, iconName: "icon_language",
            title: "kPrefMangaLang".localized(),
            subtitle: "kPrefMangaLangCur".localizedFormat(
                MDLocale.languages[MDSettingsManager.mangaLangIndex]
            )
        )
        cell.setActionType(.selector, withId: "langSelector")
        cell.delegate = self
        return cell
    }()
    private lazy var configSection = MDAccountSettingsSection(cells: [colorCell, langCell])
    
    override func setupUI() {
        view.backgroundColor = .lightestGrayF5F5F5
        
        view.addSubview(vTopArea)
        vTopArea.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        vTopArea.theme_backgroundColor = UIColor.theme_primaryColor
        
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
        lblUsername.text = MDUserManager.getInstance().username
        lblUsername.isUserInteractionEnabled = !MDUserManager.getInstance().isLoggedIn()
        lblUsername.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapUsername)))
        
        view +++ configSection
        configSection.snp.makeConstraints { make in
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
        MDUserManager.logOut {
            let vc = MDPreLoginViewController()
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    @objc private func didTapUsername() {
        if !MDUserManager.getInstance().isLoggedIn() {
            let vc = MDPreLoginViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func didUpdateSetting() {
        langCell.lblSubtitle.text = "kPrefMangaLangCur".localizedFormat(
            MDLocale.languages[MDSettingsManager.mangaLangIndex]
        )
    }
}

extension MDAccountViewController: MDAccountSettingsCellDelegate {
    func viewControllerToDisplay(forCell cell: MDAccountSettingsCell, withId id: String) -> UIViewController? {
        UIViewController()
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
