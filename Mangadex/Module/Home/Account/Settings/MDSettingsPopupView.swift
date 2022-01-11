//
//  MDSettingsPopopView.swift
//  Mangadex
//
//  Created by John Rion on 12/13/21.
//

import Foundation
import UIKit
import SwiftEntryKit
import SnapKit
import SwiftTheme

protocol MDSettingsPopupViewDelegate {
    func itemSize() -> CGSize
    func titleString() -> String
}

class MDSettingsPopupView : UIView, MDSettingsPopupViewDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    internal lazy var btnDismiss: UIButton = {
        let btn = UIButton(imgNormal: UIImage(named: "icon_dismiss"))
        btn.tintColor = MDColor.get(.darkGray808080)
        btn.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        return btn
    }()
    
    internal lazy var lblTitle = UILabel(fontSize: 24, fontWeight: .regular, color: .darkerGray565656, numberOfLines: 2, scalable: true)
    
    internal lazy var btnSave: UIButton = {
        let button = MDButton(variant: .text)
        button.setTitle("kPrefPopupSave".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()
    
    internal lazy var vOptCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.itemSize()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.decelerationRate = .fast
        view.register(MDColorSettingCollectionCell.classForCoder(), forCellWithReuseIdentifier: "colorCell")
        return view
    }()
    
    internal lazy var vSelector: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.wetAsphalt.cgColor
        view.layer.borderWidth = 2
        view.isUserInteractionEnabled = false
        return view
    }()
    
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        addSubview(btnDismiss)
        btnDismiss.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.width.height.equalTo(24)
        }
        
        addSubview(lblTitle)
        lblTitle.text = titleString()
        lblTitle.textAlignment = .center
        lblTitle.snp.makeConstraints { make in
            make.top.equalTo(btnDismiss.snp.bottom)
            make.left.right.equalToSuperview().inset(50)
        }
        
        addSubview(vOptCollection)
        vOptCollection.snp.makeConstraints { make in
            make.top.equalTo(lblTitle.snp.bottom).offset(20)
            make.height.equalTo(itemSize().height)
            make.left.right.equalToSuperview()
        }
        
        addSubview(vSelector)
        vSelector.snp.makeConstraints { make in
            make.width.equalTo(itemSize().width)
            make.centerX.equalToSuperview()
            make.top.equalTo(vOptCollection.snp.top)
            make.bottom.equalTo(vOptCollection.snp.bottom)
        }
        
        addSubview(btnSave)
        btnSave.snp.makeConstraints { make in
            make.top.equalTo(vOptCollection.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func didTapDismiss() {
        SwiftEntryKit.dismiss()
    }
    
    @objc func didTapSave() {
        fatalError("Parent Method Not Implemented By Subclass")
    }
    
    // MARK: delegate methods
    
    func itemSize() -> CGSize {
        fatalError("Parent Method Not Implemented By Subclass")
    }
    
    func titleString() -> String {
        fatalError("Parent Method Not Implemented By Subclass")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Parent Method Not Implemented By Subclass")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Parent Method Not Implemented By Subclass")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insetHorizontal = (MDLayout.screenWidth - 20 - itemSize().width) / 2
        return UIEdgeInsets(top: 0, left: insetHorizontal, bottom: 0, right: insetHorizontal)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.vOptCollection.scrollToNearestVisibleCell()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        vSelector.layer.borderColor = UIColor.wetAsphalt.withAlphaComponent(0.5).cgColor
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.vOptCollection.scrollToNearestVisibleCell()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        vSelector.layer.borderColor = UIColor.wetAsphalt.cgColor
    }
}
