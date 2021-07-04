//
//  MDMangaSlideViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/20.
//

import Foundation
import UIKit
import ProgressHUD

class MDMangaSlideViewController: MDViewController {
    // MARK: - properties
    var mangaId: String!
    var volume: String!
    var chapter: String!
    
    var pages: [String] = []
    lazy var vSlider: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: MDLayout.screenWidth, height: MDLayout.screenHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(MDMangaSlideCollectionCell.self, forCellWithReuseIdentifier: "page")

        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(showHideAppBar(recognizer: )))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }()
    
    // MARK: - initialize
    static func initWithMangaId(_ id: String, volume: String, chapter: String) -> MDMangaSlideViewController {
        let vc = MDMangaSlideViewController()
        vc.viewTitle = "\("kVolume".localized()) \(volume) - \(chapter) \("kChapter".localized())"
        vc.mangaId = id
        vc.volume = volume
        vc.chapter = chapter
        return vc
    }
    
    override func setupUI() {
        setupNavBar(backgroundColor: .black, preserveStatus: false)
        
        view.backgroundColor = .black
        
        view.addSubview(appBar!)
        appBar!.snp.makeConstraints { make in
            make.top.equalTo(MDLayout.safeAreaInsets(false).top)
            make.left.right.equalToSuperview()
        }
        
        view.insertSubview(vSlider, belowSubview: appBar!)
        vSlider.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        ProgressHUD.show()
        let client = MDHTTPManager()
        client.getChapterIdByMangaId(mangaId, volume: volume, chapter: self.chapter) { data in
            client.getChapterBaseUrlById(data.id) { url in
                for name in data.attributes.data {
                    self.pages.append("\(url)/data/\(data.attributes.chapterHash!)/\(name)")
                }
                DispatchQueue.main.async {
                    self.vSlider.reloadData()
                    let transform = self.appBar?.transform.translatedBy(x: 0, y: -(self.appBar?.frame.height)!)
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                        self.appBar?.transform = transform!
                    } completion: { status in
                        self.appBar?.isHidden = true
                    }
                    ProgressHUD.dismiss()
                }
            }
        }
    }

    @objc private func showHideAppBar(recognizer: UITapGestureRecognizer) {
        if (appBar?.isHidden == true) {
            appBar?.isHidden = false
            let transform = appBar?.transform.translatedBy(x: 0, y: (appBar?.frame.height)!)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                self.appBar?.transform = transform!
            }
        } else {
            let transform = appBar?.transform.translatedBy(x: 0, y: -(appBar?.frame.height)!)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                self.appBar?.transform = transform!
            } completion: { status in
                self.appBar?.isHidden = true
            }
        }
    }
}

// MARK: - collectionView
extension MDMangaSlideViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath)
                as! MDMangaSlideCollectionCell
        cell.ivPage.kf.setImage(with: URL(string: pages[indexPath.row]))
        cell.scrollBack = {
            if (indexPath.row > 0) {
                let newIndex = IndexPath(row: indexPath.row - 1, section: 1)
                collectionView.scrollToItem(at: newIndex, at: .centeredHorizontally, animated: true)
            }
        }
        cell.scrollForward = {
            if (indexPath.row < self.pages.count) {
                let newIndex = IndexPath(row: indexPath.row + 1, section: 1)
                collectionView.scrollToItem(at: newIndex, at: .centeredHorizontally, animated: true)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }
}
