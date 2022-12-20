//
//  MDMangaDetailChapterViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

//import Foundation
//import UIKit
//import SwiftEventBus
//import XLPagerTabStrip
//import PromiseKit
//import MJRefresh
//
//class MDMangaDetailChapterViewController: MDViewController {
//    // MARK: - properties
//    private var mangaModel: MDMangaItemDataModel!
//    private var chapterModels = [MDMangaChapterInfoModel]()
//    private var totalChapters: Int!
//
//    private var lastViewedChapterId: String?
//    private var lastViewedChapterIndex: IndexPath?
//
//    private var cvChapters: UICollectionView!
//
//    private lazy var refreshHeader = MJRefreshNormalHeader {
//        self.reloadChapters()
//    }
//
//    private lazy var refreshFooter = MJRefreshBackNormalFooter {
//        self.loadMoreChapters()
//    }
//
//    private lazy var vProgress: UIActivityIndicatorView = {
//        let view = UIActivityIndicatorView(style: .large)
//        view.hidesWhenStopped = true
//        view.theme_color = UIColor.theme_primaryColor
//        return view
//    }()
//
//    // MARK: - initialize
//    convenience init(mangaModel: MDMangaItemDataModel) {
//        self.init()
//        self.mangaModel = mangaModel
//
//        let layout = UICollectionViewFlowLayout()
//        // four chapter cells per row
//        layout.itemSize = .init(width: (MDLayout.screenWidth - 2 * 15 - 3 * 10) / 4, height: 45)
//
//        cvChapters = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cvChapters.backgroundColor = .white
//        cvChapters.delegate = self
//        cvChapters.dataSource = self
//        cvChapters.contentInsetAdjustmentBehavior = .never
//        cvChapters.contentInset = .cssStyle(-20, 15, MDLayout.adjustedSafeInsetBottom)
//        cvChapters.showsVerticalScrollIndicator = false
//        cvChapters.register(MDMangaDetailChapterCollectionCell.self, forCellWithReuseIdentifier: "chapter")
//    }
//
//    override func setupUI() {
//        view.addSubview(cvChapters)
//        cvChapters.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        cvChapters.mj_header = refreshHeader
//        cvChapters.mj_header?.isHidden = true
//        cvChapters.mj_header?.ignoredScrollViewContentInsetTop = -20
//
//        cvChapters.mj_footer = refreshFooter
//        cvChapters.mj_footer?.isHidden = true
//        cvChapters.mj_footer?.ignoredScrollViewContentInsetBottom = MDLayout.adjustedSafeInsetBottom
//
//        view.insertSubview(vProgress, aboveSubview: cvChapters)
//        vProgress.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            make.bottom.equalToSuperview().inset(48)
//        }
//    }
//
//    override func didSetupUI() {
//        lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: mangaModel.id)
//
//        vProgress.startAnimating()
//        firstly {
//            MDRequests.Chapter.getListForManga(
//                mangaId: mangaModel.id,
//                offset: 0,
//                locale: MDLocale.currentMangaLanguage,
//                order: .ASC
//            )
//        }.done { result in
//            DispatchQueue.main.async {
//                self.chapterModels = result.data
//                self.totalChapters = result.total
//
//                self.cvChapters.mj_header?.isHidden = false
//                if self.chapterModels.count < self.totalChapters {
//                    self.cvChapters.mj_footer?.isHidden = false
//                }
//
//                self.cvChapters.reloadData()
//                self.vProgress.stopAnimating()
//
//                SwiftEventBus.onMainThread(self, name: "openChapter") { result in
//                    if (self.lastViewedChapterIndex == nil) {
//                        self.lastViewedChapterIndex = IndexPath(row: 0, section: 0)
//                    }
//                    self.viewManga(indexPath: self.lastViewedChapterIndex!)
//                }
//            }
//        }
//    }
//
//    private func viewManga(indexPath: IndexPath) {
//        let vc = MDMangaSlideViewController(
//            chapterInfo: chapterModels[indexPath.row],
//            currentIndex: indexPath.row,
//            requirePrevAction: { index in
//                index > 0 ? self.chapterModels[index - 1] : nil
//            },
//            requireNextAction: { index in
//                index < self.chapterModels.count - 1 ? self.chapterModels[index + 1] : nil
//            },
//            enterPageAction: { chapterId in
//                MDMangaProgressManager.saveProgress(forMangaId: self.mangaModel.id, chapterId: chapterId)
//            },
//            leavePageAction: {
//                self.lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: self.mangaModel.id)
//                self.cvChapters.reloadData()
//            }
//        )
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    private func reloadChapters() {
//        self.cvChapters.mj_footer?.isHidden = true
//        firstly {
//            MDRequests.Chapter.getListForManga(
//                mangaId: mangaModel.id,
//                offset: 0,
//                locale: MDLocale.currentMangaLanguage,
//                order: .ASC
//            )
//        }.done { result in
//            DispatchQueue.main.async {
//                self.chapterModels = result.data
//                self.totalChapters = result.total
//
//                if self.chapterModels.count < self.totalChapters {
//                    self.cvChapters.mj_footer?.isHidden = false
//                }
//
//                self.cvChapters.reloadData()
//                self.cvChapters.mj_header?.endRefreshing()
//            }
//        }
//    }
//
//    private func loadMoreChapters() {
//        firstly {
//            MDRequests.Chapter.getListForManga(
//                mangaId: mangaModel.id,
//                offset: chapterModels.count,
//                locale: MDLocale.currentMangaLanguage,
//                order: .ASC
//            )
//        }.done { result in
//            DispatchQueue.main.async {
//                self.chapterModels.append(contentsOf: result.data)
//                self.totalChapters = result.total
//
//                self.cvChapters.reloadData()
//                self.cvChapters.mj_footer?.endRefreshing()
//
//                if self.chapterModels.count == self.totalChapters {
//                    self.cvChapters.mj_footer?.isHidden = true
//                }
//            }
//        }
//    }
//}
//
//// MARK: - collectionView delegate
//extension MDMangaDetailChapterViewController: UICollectionViewDelegate,
//                                              UICollectionViewDataSource,
//                                              UICollectionViewDelegateFlowLayout,
//                                              IndicatorInfoProvider {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int
//    ) -> Int {
//        chapterModels.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "chapter",
//            for: indexPath
//        )
//            as! MDMangaDetailChapterCollectionCell
//
//        let model = chapterModels[indexPath.row]
//        let lastViewed = model.id == lastViewedChapterId
//        cell.update(model: model, lastViewed: lastViewed)
//        if lastViewed {
//            lastViewedChapterIndex = indexPath
//        }
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        viewManga(indexPath: indexPath)
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        referenceSizeForHeaderInSection section: Int
//    ) -> CGSize {
//        CGSize(width: collectionView.frame.width, height: 40)
//    }
//
//    public func indicatorInfo(
//        for pagerTabStripController: PagerTabStripViewController
//    ) -> IndicatorInfo {
//        IndicatorInfo(title: "kMangaDetailChapters".localized())
//    }
//}
