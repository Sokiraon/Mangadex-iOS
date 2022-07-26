//
//  MDMangaDetailInfoViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import UIKit
import SnapKit
import XLPagerTabStrip
import Down
import MaterialComponents.MaterialCards

class MDMangaDetailInfoHeader: UICollectionReusableView {
    let label = UILabel(fontSize: 18, fontWeight: .medium)
    let divider = UIView()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        addSubview(divider)
        divider.theme_backgroundColor = UIColor.theme_primaryColor
        divider.layer.cornerRadius = 1
        divider.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.top.equalTo(label.snp.bottom).offset(4)
            make.right.equalTo(label.snp.right).offset(12)
            make.left.bottom.equalToSuperview()
        }
    }
}

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
    
    func setContent(tagName: String) {
        lblTag.text = tagName
    }
}

class MDMangaDetailInfoViewController: MDViewController {
    private var mangaItem: MangaItem?
    
    private lazy var vScroll = UIScrollView(bounce: .vertical, showIndicator: false)
    private lazy var vScrollContent = UIView()
    
    private lazy var descrCard = MDCTextCard(title: "kDescription".localized(), content: "kMangaNoDescr".localized())
    private lazy var tagsCard = MDCCustomCard(title: "kTags".localized())
    
    private lazy var tagsCollection: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.isScrollEnabled = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(MDMangaDetailInfoTagCell.self, forCellWithReuseIdentifier: "tag")
        view.register(
            MDMangaDetailInfoHeader.self,
            forSupplementaryViewOfKind: .CollectionViewSectionHeaderKind,
            withReuseIdentifier: "header"
        )
        return view
    }()
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .estimated(80),
                heightDimension: .absolute(40)
            )
        )
        item.edgeSpacing = .init(
            leading: .fixed(0),
            top: .fixed(10),
            trailing: .fixed(5),
            bottom: .fixed(10)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(5)
        group.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: .CollectionViewSectionHeaderKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) in
            if self.mangaItem?.tags[sectionIndex].count ?? 0 > 0 {
                return section
            } else {
                return nil
            }
        }
        
        return layout
    }
    
    convenience init(mangaItem item: MangaItem) {
        self.init()
        mangaItem = item
        let descrStr = try? Down(markdownString: item.description).toAttributedString()
        descrCard.update(attributedContent: descrStr)
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
        descrCard.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.right.equalToSuperview().inset(12)
        }
    
        tagsCard.setShadowElevation(.none, for: .normal)
        tagsCard.applyBorder()
        vScrollContent.addSubview(tagsCard)
        tagsCard.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(descrCard.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(MDLayout.adjustedSafeInsetBottom)
        }
        
        tagsCard.contentView.addSubview(tagsCollection)
        tagsCollection.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(140)
        }
    }
    
    override func doOnAppear() {
        tagsCollection.layoutIfNeeded()
        tagsCollection.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(tagsCollection.contentSize.height)
        }
        tagsCollection.setNeedsLayout()
        tagsCollection.layoutIfNeeded()
    }
}

extension MDMangaDetailInfoViewController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           IndicatorInfoProvider {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        mangaItem?.tags.count ?? 0
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        mangaItem?.tags[section].count ?? 0
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "tag", for: indexPath
        ) as! MDMangaDetailInfoTagCell
        if let tagName = mangaItem?.tags[indexPath.section][indexPath.row] {
            cell.setContent(tagName: tagName)
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: .CollectionViewSectionHeaderKind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as! MDMangaDetailInfoHeader
        switch indexPath.section {
            case 0:
                view.label.text = "kMangaTagTypeFormat".localized()
                break
            case 1:
                view.label.text = "kMangaTagTypeGenre".localized()
                break
            case 2:
                view.label.text = "kMangaTagTypeTheme".localized()
                break
            default:
                view.label.text = "kMangaTagTypeContent".localized()
                break
        }
        return view
    }
    
    public func indicatorInfo(
        for pagerTabStripController: PagerTabStripViewController
    ) -> IndicatorInfo {
        IndicatorInfo(title: "kMangaDetailInfo".localized())
    }
}
