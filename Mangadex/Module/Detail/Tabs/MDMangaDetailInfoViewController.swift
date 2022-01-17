//
//  MDMangaDetailInfoViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import AlignedCollectionViewFlowLayout
import XLPagerTabStrip

class MDMangaDetailInfoTagCell: UICollectionViewCell {
    private var lblTag = UILabel(color: .darkerGray565656)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .lightGrayE5E5E5
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(0)
            make.height.equalTo(40)
        }
        contentView.layer.cornerRadius = 20
        
        contentView.addSubview(lblTag)
        lblTag.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
    }
    
    func updateWithTag(_ tag: String) {
        lblTag.text = tag
    }
}

class MDMangaDetailInfoViewController: MDViewController {
    private var mangaItem: MangaItem?
    
    private lazy var vScroll = UIScrollView(bounce: .vertical, showIndicator: false)
    private lazy var vScrollContent = UIView()
    
    private lazy var descrCard = MDCTextCard(title: "kDescription".localized(), message: "")
    private lazy var tagsCard = MDCCustomCard(title: "kTags".localized())
    
    private lazy var tagsCollection: UICollectionView = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isScrollEnabled = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(MDMangaDetailInfoTagCell.self, forCellWithReuseIdentifier: "tag")
        return view
    }()
    
    convenience init(mangaItem item: MangaItem) {
        self.init()
        mangaItem = item
        descrCard.updateContent(message: item.description)
    }
    
    override func setupUI() {
        view.addSubview(vScroll)
        vScroll.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
        }
        
        vScroll.addSubview(vScrollContent)
        vScrollContent.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        descrCard.setShadowElevation(.none, for: .normal)
        descrCard.applyBorder()
        vScrollContent.addSubview(descrCard)
        descrCard.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(15)
            make.left.right.equalToSuperview().inset(10)
        }
        
        tagsCard.setShadowElevation(.none, for: .normal)
        tagsCard.applyBorder()
        vScrollContent.addSubview(tagsCard)
        tagsCard.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(descrCard.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(MDLayout.adjustedSafeInsetBottom)
        }
        
        tagsCard.contentView.addSubview(tagsCollection)
        tagsCollection.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(140)
        }
    }
}

extension MDMangaDetailInfoViewController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           IndicatorInfoProvider {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        mangaItem?.tags.count ?? 0
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tag", for: indexPath)
            as! MDMangaDetailInfoTagCell
        cell.updateWithTag(mangaItem?.tags[indexPath.row] ?? "N/A")
        return cell
    }
    
    public func indicatorInfo(
        for pagerTabStripController: PagerTabStripViewController
    ) -> IndicatorInfo {
        IndicatorInfo(title: "kMangaDetailInfo".localized())
    }
}
