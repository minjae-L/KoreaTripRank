//
//  ViewController.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/2/24.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    // Navigation Toolbar Setup
    lazy var toolbar: UIToolbar = {
        let tb = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        tb.isTranslucent = false
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    private func setUpNavigationToolbar() {
        let appearance = UIToolbarAppearance()
        appearance.backgroundColor = .white
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .done, target: self, action: #selector(favoriteButtonTapped))
        let mainViewButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .done, target: self, action: #selector(listButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.scrollEdgeAppearance = appearance
        let items = [space, mainViewButton,space, space, favoriteButton, space]
        toolbar.setItems(items, animated: false)
    }
    // Toolbar Button Event
    @objc func favoriteButtonTapped() {
        pageView.setViewControllers([favoriteVC], direction: .forward, animated: false)
    }
    @objc func listButtonTapped() {
        pageView.setViewControllers([searchVC], direction: .forward, animated: false)
    }
    // PageView Set up
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var searchVC = SearchViewController()
    lazy var favoriteVC = FavoriteViewController()
    lazy var viewControllers = [self.searchVC, self.favoriteVC]
    lazy var pageView: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.delegate = self
        vc.dataSource = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private func addView() {
        view.addSubview(toolbar)
        view.addSubview(containerView)
        containerView.addSubview(pageView.view)
        addChild(pageView)
    }
    private func configureLayout() {
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view.layoutMarginsGuide)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.layoutMarginsGuide)
            make.bottom.equalTo(self.toolbar.snp.top)
            make.leading.trailing.equalTo(self.view)
            make.trailing.equalTo(self.view)
        }
        pageView.view.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.containerView)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        setUpNavigationToolbar()
        configureLayout()
        if let firstVC = viewControllers.first {
            pageView.setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
}

// MARK: UIPageView Delegate, DataSource
extension MainViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else { return nil}
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == viewControllers.count {
            return nil
        }
        return viewControllers[nextIndex]
    }
    
    
}
