//
//  AgrumeCoverActionHelper.swift
//  Mangadex
//
//  Created by OpenAI Codex on 2026/5/24.
//

import UIKit
import ProgressHUD

final class AgrumeCoverActionHelper: NSObject {

    func makeLongPressHandler(for image: UIImage?, viewController: UIViewController) {
        guard let image else {
            ProgressHUD.failed("manga.detail.cover.action.unavailable".localized())
            return
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = viewController.view
        alert.popoverPresentationController?.sourceRect = CGRect(
            x: viewController.view.bounds.midX,
            y: viewController.view.bounds.midY,
            width: 0,
            height: 0
        )

        alert.addAction(UIAlertAction(
            title: "manga.detail.cover.action.save".localized(),
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            UIImageWriteToSavedPhotosAlbum(
                image,
                self,
                #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                nil
            )
        })

        alert.addAction(UIAlertAction(
            title: "manga.detail.cover.action.share".localized(),
            style: .default
        ) { _ in
            self.presentShareSheet(for: image, from: viewController)
        })

        alert.addAction(UIAlertAction(
            title: "kCancel".localized(),
            style: .cancel
        ))

        viewController.present(alert, animated: true)
    }

    private func presentShareSheet(
        for image: UIImage,
        from viewController: UIViewController
    ) {
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(
            x: viewController.view.bounds.midX,
            y: viewController.view.bounds.midY,
            width: 0,
            height: 0
        )
        viewController.present(activityViewController, animated: true)
    }

    @objc
    private func image(
        _ image: UIImage,
        didFinishSavingWithError error: NSError?,
        contextInfo: UnsafeRawPointer
    ) {
        if error == nil {
            ProgressHUD.succeed("manga.detail.cover.action.saveSucceeded".localized())
        } else {
            ProgressHUD.failed("manga.detail.cover.action.saveFailed".localized())
        }
    }
}
