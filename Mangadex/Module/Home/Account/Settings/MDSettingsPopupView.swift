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

public let SettingsPopupViewWillDisAppear = "SettingsPopupViewWillDisAppear"

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
        btn.tintColor = .darkGray808080
        btn.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        return btn
    }()
    
    internal lazy var lblTitle = UILabel(fontSize: 24, fontWeight: .regular, color: .darkerGray565656, numberOfLines: 2, scalable: true)
    
    internal lazy var vOptCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.itemSize()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.bounces = false
        view.decelerationRate = .fast
        view.showsHorizontalScrollIndicator = false
        view.register(MDColorSettingCollectionCell.self, forCellWithReuseIdentifier: "colorCell")
        view.register(MDLangSettingCollectionCell.self, forCellWithReuseIdentifier: "langCell")
        return view
    }()
    
    internal lazy var vCollectionBackground = UIView(backgroundColor: .lightestGrayF5F5F5)

    let selectorColor = UIColor.amethyst
    
    internal lazy var vSelector: UIView = {
        let view = UIView()
        view.layer.borderColor = selectorColor.cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 10
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
        vOptCollection.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        vOptCollection.snp.makeConstraints { make in
            make.top.equalTo(lblTitle.snp.bottom).offset(30)
            make.bottom.equalToSuperview().inset(30)
            make.height.equalTo(itemSize().height + 10)
            make.left.right.equalToSuperview()
        }
        
        addSubview(vSelector)
        vSelector.snp.makeConstraints { make in
            make.width.equalTo(itemSize().width)
            make.height.equalTo(itemSize().height)
            make.centerX.centerY.equalTo(vOptCollection)
        }
    }
    
    @objc func didTapDismiss() {
        SwiftEntryKit.dismiss()
    }
    
    /**
     CollectionView will not scroll if target item is already in position,
     so we need to check for this situation here and manually invoke the callback function.
     */
    func scrollViewWillScrollToIndexPath(_ indexPath: IndexPath?) -> Bool {
        if let indexPath = indexPath {
            let itemWidth = itemSize().width
            var targetCenterX = itemWidth / 2
            if indexPath.row > 0 {
                targetCenterX += itemWidth * CGFloat(indexPath.row)
                targetCenterX += (
                    (vOptCollection.collectionViewLayout as? UICollectionViewFlowLayout)?
                        .minimumLineSpacing ?? 0
                ) * CGFloat(indexPath.row)
            }
            let currentCenterX = vOptCollection.contentOffset.x + itemWidth / 2
            if abs(targetCenterX - currentCenterX) < 1 {
                return false
            }
        }
        return true
    }
    
    // MARK: lifecycle events
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
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
        if scrollViewWillScrollToIndexPath(indexPath) {
            vSelector.layer.borderColor = selectorColor.withAlphaComponent(0.5).cgColor
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insetHorizontal = (MDLayout.screenWidth - 20 - itemSize().width) / 2
        return UIEdgeInsets(top: 0, left: insetHorizontal, bottom: 0, right: insetHorizontal)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPath = vOptCollection.scrollToNearestVisibleCell()
        if !scrollViewWillScrollToIndexPath(indexPath) {
            scrollViewDidEndScrollingAnimation(scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        vSelector.layer.borderColor = selectorColor.withAlphaComponent(0.5).cgColor
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let indexPath = vOptCollection.scrollToNearestVisibleCell()
            if !scrollViewWillScrollToIndexPath(indexPath) {
                scrollViewDidEndScrollingAnimation(scrollView)
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        vSelector.layer.borderColor = selectorColor.cgColor
        
        let collectionCenter = vOptCollection.contentOffset.x + vOptCollection.bounds.width / 2
        guard let indexPath = vOptCollection.indexPathForItem(
            at: CGPoint(x: collectionCenter, y: vOptCollection.bounds.height / 2)
        ) else { return }
        
        scrollViewDidEndScrollingAnimation(scrollView, atIndexPath: indexPath)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView, atIndexPath indexPath: IndexPath) {}
}
