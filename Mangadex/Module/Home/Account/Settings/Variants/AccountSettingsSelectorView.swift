//
//  AccountSettingsSelectorView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/17.
//

import Foundation
import UIKit
import SnapKit
import SwiftEntryKit

class AccountSettingsSelectorView: UIView {
    
    let dismissButton: UIButton = {
        let button = ImageButton(image: .init(named: "icon_dismiss"))
        button.tintColor = .darkGray808080
        button.addAction(UIAction { _ in
            SwiftEntryKit.dismiss()
        }, for: .touchUpInside)
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
                              primaryAction: UIAction { _ in
            self.delegate?.onSubmit(Array(self._selectedKeys))
            SwiftEntryKit.dismiss()
        })
        return button
    }()
    
    let title = UILabel(fontSize: 21, alignment: .center, scalable: true)
    
    weak var delegate: AccountSettingsSelectorCell? {
        didSet {
            setupDataSource()
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Int, String>!
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
            make.right.equalTo(dismissButton.snp.left).offset(-8)
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
            make.top.equalTo(title.snp.bottom).offset(16)
        }
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private var _keys: [String] {
        delegate?.keys ?? []
    }
    private var _selectedKeys = Set<String>()
    private var allowMultiple = false
    
    func setupDataSource() {
        title.text = delegate?.popupTitle
        allowMultiple = delegate?.allowMultiple ?? false
        _selectedKeys = Set(delegate?.selectedKeysProvider() ?? [])
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String>
        { cell, indexPath, key in
            self.delegate?.itemDecorator(cell, indexPath, key)
            cell.backgroundConfiguration = .clear()
            if self._selectedKeys.contains(key) {
                cell.accessories = [.checkmark()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(_keys, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension AccountSettingsSelectorView: UICollectionViewDelegate {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        let key = _keys[indexPath.item]
        if _selectedKeys.contains(key),
           _selectedKeys.count > 1,
           allowMultiple {
            _selectedKeys.remove(key)
            cell.accessories = []
        }
        else if !_selectedKeys.contains(key) {
            if allowMultiple {
                _selectedKeys.insert(key)
            } else {
                let previousKey = _selectedKeys.first!
                let previousIndex = _keys.firstIndex(of: previousKey)!
                let previousIndexPath = IndexPath(item: previousIndex, section: 0)
                let previousCell = collectionView.cellForItem(at: previousIndexPath) as! UICollectionViewListCell
                previousCell.accessories = []
                _selectedKeys = [key]
            }
            cell.accessories = [.checkmark()]
        }
    }
}
