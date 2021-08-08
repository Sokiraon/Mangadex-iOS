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
        button.addAction(UIAction(handler: { action in
            MDUserManager.logOut {
                let vc = MDPreLoginViewController()
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        }), for: .touchUpInside)
        button.isHidden = !MDUserManager.getInstance().isLoggedIn()
        return button
    }()
    
    private lazy var colorCard = MDCCustomCard(title: "kThemeColor".localized())
    private lazy var colorCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 90)
        layout.minimumInteritemSpacing = 25
        layout.minimumLineSpacing = 15
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isScrollEnabled = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(MDColorSettingsCollectionCell.self, forCellWithReuseIdentifier: "color")
        
        return view
    }()
    
    
    override func setupUI() {
        view.backgroundColor = MDColor.get(.lighterGrayF5F5F5)
        
        view.addSubview(vTopArea)
        vTopArea.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        vTopArea.theme_backgroundColor = MDColor.ThemeColors.tint
        
        vTopArea.addSubview(ivAvatar)
        ivAvatar.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop + 30)
            make.left.equalToSuperview().inset(25)
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
        
        view.addSubview(colorCard)
        colorCard.snp.makeConstraints { make in
            make.top.equalTo(vTopArea.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(10)
        }
        
        colorCard.contentView.addSubview(colorCollection)
        colorCollection.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(ceil(Double(MDThemeColors.allCases.count) / 3.0) * 105)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @objc private func didTapUsername() {
        if !MDUserManager.getInstance().isLoggedIn() {
            let vc = MDPreLoginViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MDAccountViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MDThemeColors.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "color", for: indexPath) as! MDColorSettingsCollectionCell
        cell.setWithIndex(indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ThemeManager.setTheme(index: indexPath.row)
        let cells = collectionView.visibleCells.enumerated()
        for (_, cell) in cells {
            (cell as! MDColorSettingsCollectionCell).updateUIIfNeeded()
        }
    }
}
