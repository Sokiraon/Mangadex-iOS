//
// Created by Codex on 2026/5/12.
//

import UIKit
import SnapKit

struct MDPagerPage {
    let title: String
    let viewController: UIViewController
}

class MDPagerViewController: UIViewController {
    private let tabBar = CardView().apply { view in
        view.cornerRadius = 16
        view.shadowCornerRadius = 16
        view.fillColor = .lighterGrayEFEFEF
        view.borderColor = .white
        view.borderWidth = .native1px * 2
        view.shadowOpacity = 0.1
    }
    private let buttonStack = UIStackView()
    private let selectedTabBackgroundView = UIView()
    private let indicatorView = UIView()
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    private var pageItems: [MDPagerPage] { pages }
    private var buttons: [UIButton] = []

    private(set) var currentIndex = 0

    var pages: [MDPagerPage] {
        []
    }

    var tabBarHeight: CGFloat {
        48
    }

    var tabBarContentInsets: NSDirectionalEdgeInsets {
        .all(4)
    }

    var tabButtonContentInsets: NSDirectionalEdgeInsets {
        .cssStyle(8, 6)
    }

    var pageBounces: Bool {
        true
    }

    var selectionAnimationDuration: TimeInterval {
        0.34
    }

    var indicatorAnimationDuration: TimeInterval {
        0.34
    }

    var indicatorExtraWidth: CGFloat {
        8
    }

    var overlaysTabBarOnPageContent: Bool {
        false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPages()
        updateSelectedTab(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSelectedTabChrome(animated: false)
    }

    func selectPage(at index: Int, animated: Bool) {
        guard pageItems.indices.contains(index) else { return }
        guard index != currentIndex else {
            updateSelectedTab(animated: animated)
            return
        }

        let previousIndex = currentIndex
        let direction: UIPageViewController.NavigationDirection = index > currentIndex
            ? .forward
            : .reverse
        let targetViewController = pageItems[index].viewController
        currentIndex = index
        updateSelectedTab(animated: animated)

        pageViewController.setViewControllers(
            [targetViewController],
            direction: direction,
            animated: animated
        ) { [weak self] completed in
            guard let self else { return }
            if !completed && animated {
                self.currentIndex = previousIndex
                self.updateSelectedTab(animated: true)
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            if view.safeAreaInsets.top > 0 {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(8)
            }
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(tabBarHeight)
        }

        selectedTabBackgroundView.backgroundColor = .white
        selectedTabBackgroundView.isUserInteractionEnabled = false
        selectedTabBackgroundView.layer.cornerCurve = .continuous
        selectedTabBackgroundView.layer.shadowColor = UIColor.black.cgColor
        selectedTabBackgroundView.layer.shadowOpacity = 0.08
        selectedTabBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        selectedTabBackgroundView.layer.shadowRadius = 3
        tabBar.addSubview(selectedTabBackgroundView)

        indicatorView.backgroundColor = .themeDark
        indicatorView.layer.cornerRadius = 1.5
        tabBar.addSubview(indicatorView)

        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        tabBar.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(tabBarContentInsets)
        }

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            if overlaysTabBarOnPageContent {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(tabBar.snp.bottom)
            }
        }
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        view.bringSubviewToFront(tabBar)
    }

    private func setupPages() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons = pageItems.enumerated().map { index, page in
            let button = makeTabButton(title: page.title, index: index)
            buttonStack.addArrangedSubview(button)
            return button
        }

        if let firstViewController = pageItems.first?.viewController {
            pageViewController.setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: false
            )
        }
        updatePageScrollBehavior()
    }

    private func makeTabButton(title: String, index: Int) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .darkGray808080
        config.background.backgroundColor = .clear
        config.contentInsets = tabButtonContentInsets
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 18, weight: .medium)
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.tag = index
        button.addTarget(self, action: #selector(didTapTab(_:)), for: .touchUpInside)
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.baseForegroundColor = button.isSelected
                ? .themeDark
                : .darkGray808080
            config?.background.backgroundColor = .clear
            button.configuration = config
        }
        return button
    }

    @objc private func didTapTab(_ sender: UIButton) {
        selectPage(at: sender.tag, animated: true)
    }

    private func updateSelectedTab(animated: Bool) {
        for (index, button) in buttons.enumerated() {
            button.isSelected = index == currentIndex
            button.setNeedsUpdateConfiguration()
        }
        updateSelectedTabChrome(animated: animated)
    }

    private func updateSelectedTabChrome(animated: Bool) {
        updateSelectedTabBackground(animated: animated)
        updateIndicator(animated: animated)
    }

    private func updateSelectedTabBackground(animated: Bool) {
        guard buttons.indices.contains(currentIndex) else { return }
        tabBar.layoutIfNeeded()
        buttonStack.layoutIfNeeded()

        let buttonFrame = buttons[currentIndex].convert(
            buttons[currentIndex].bounds,
            to: tabBar
        )
        guard buttonFrame.width > 0, tabBar.bounds.height > 0 else { return }

        let targetFrame = buttonFrame.insetBy(dx: 0, dy: 0)

        let animations = {
            self.selectedTabBackgroundView.frame = targetFrame
            self.selectedTabBackgroundView.layer.cornerRadius = targetFrame.height / 2
            self.selectedTabBackgroundView.layer.shadowPath = UIBezierPath(
                roundedRect: self.selectedTabBackgroundView.bounds,
                cornerRadius: self.selectedTabBackgroundView.layer.cornerRadius
            ).cgPath
        }
        if animated {
            UIView.animate(
                withDuration: selectionAnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: 0.6,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: animations
            )
        } else {
            animations()
        }
    }

    private func updateIndicator(animated: Bool) {
        guard buttons.indices.contains(currentIndex) else { return }
        tabBar.layoutIfNeeded()
        buttonStack.layoutIfNeeded()

        let buttonFrame = buttons[currentIndex].convert(
            buttons[currentIndex].bounds,
            to: tabBar
        )
        guard buttonFrame.width > 0, tabBar.bounds.height > 0 else { return }

        let titleWidth = buttons[currentIndex]
            .titleLabel?
            .intrinsicContentSize
            .width ?? 0
        let indicatorWidth = min(
            buttonFrame.width,
            max(24, titleWidth + indicatorExtraWidth)
        )
        let targetFrame = CGRect(
            x: buttonFrame.midX - indicatorWidth / 2,
            y: tabBar.bounds.height - 5,
            width: indicatorWidth,
            height: 3
        )

        let animations = {
            self.indicatorView.frame = targetFrame
        }
        if animated {
            UIView.animate(
                withDuration: indicatorAnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: 0.6,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: animations
            )
        } else {
            animations()
        }
    }

    private func updatePageScrollBehavior() {
        let scrollViews = pageViewController.view.subviews.compactMap {
            $0 as? UIScrollView
        }
        scrollViews.forEach { scrollView in
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.bounces = pageBounces
        }
    }
}

extension MDPagerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = pageItems.firstIndex(where: { $0.viewController === viewController }),
            index > 0
        else {
            return nil
        }
        return pageItems[index - 1].viewController
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = pageItems.firstIndex(where: { $0.viewController === viewController }),
            index < pageItems.count - 1
        else {
            return nil
        }
        return pageItems[index + 1].viewController
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            completed,
            let visibleViewController = pageViewController.viewControllers?.first,
            let index = pageItems.firstIndex(where: { $0.viewController === visibleViewController })
        else {
            return
        }
        currentIndex = index
        updateSelectedTab(animated: true)
    }
}
