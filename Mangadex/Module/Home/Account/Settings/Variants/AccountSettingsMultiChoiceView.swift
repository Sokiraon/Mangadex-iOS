//
//  AccountSettingsMultiChoiceView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/15.
//

import Foundation
import UIKit
import SnapKit
import SwiftEntryKit

class AccountSettingsMultiChoiceView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var dismissButton: UIButton = {
        let button = ImageButton(image: .init(named: "icon_dismiss"))
        button.tintColor = .darkGray808080
        button.addTarget(self,
                         action: #selector(didTapDismiss),
                         for: .touchUpInside)
        return button
    }()
    lazy var submitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "kOk".localized()
        config.buttonSize = .medium
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .themePrimary
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config,
                              primaryAction: UIAction { _ in self.didTapSubmit() })
        return button
    }()
    
    let title = UILabel(fontSize: 21, alignment: .center, scalable: true)
    
    var delegate: AccountSettingsMultiChoiceCell? {
        didSet {
            title.text = delegate?.popUpTitle
            setupDataSource()
        }
    }
    
    enum Section: Int {
        case main
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 8
        
        addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(24)
        }
        
        addSubview(title)
        title.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(dismissButton)
            make.right.equalTo(dismissButton.snp.left).offset(-16)
        }
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(12)
        }
        
        let listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.left.right.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(12)
            make.bottom.equalTo(submitButton.snp.top).offset(-12)
        }
    }
    
    func setupDataSource() {
        _selectedKeys = delegate?.selectedKeysProvider() ?? []
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String>
        { cell, indexPath, key in
            self.delegate?.choiceItemUpdater(cell, indexPath, key)
            cell.backgroundConfiguration = .clear()
            if self._selectedKeys.contains(key) {
                cell.accessories = [.checkmark()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(_keys, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private var _keys: [String] {
        delegate?.keys ?? []
    }
    private var _selectedKeys: Set<String> = []
    
    @objc func didTapSubmit() {
        delegate?.onSubmit(_selectedKeys)
        SwiftEntryKit.dismiss()
    }
    
    @objc func didTapDismiss() {
        SwiftEntryKit.dismiss()
    }
}

extension AccountSettingsMultiChoiceView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        let key = _keys[indexPath.item]
        if _selectedKeys.contains(key) {
            _selectedKeys.remove(key)
            cell.accessories = []
        } else {
            _selectedKeys.insert(key)
            cell.accessories = [.checkmark()]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        cell.backgroundColor = .grayDFDFDF
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        UIView.animate(withDuration: 0.2) {
            cell.backgroundColor = .clear
        }
    }
}
