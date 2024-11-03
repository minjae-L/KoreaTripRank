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
    private func setUpNavigationToolbar() {
        self.navigationController?.isToolbarHidden = false
        
        let appearance = UIToolbarAppearance()
        appearance.backgroundColor = .white
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .done, target: self, action: #selector(favoriteButtonTapped))
        let mainViewButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .done, target: self, action: #selector(listButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.navigationController?.toolbar.scrollEdgeAppearance = appearance
        self.navigationController?.toolbar.isTranslucent = false
        let items = [space, mainViewButton, space, space, favoriteButton, space]
        self.toolbarItems = items
    }
    // Toolbar Button Event
    @objc func favoriteButtonTapped() {
        pageView.setViewControllers([favoriteVC], direction: .forward, animated: false)
    }
    @objc func listButtonTapped() {
        pageView.setViewControllers([searchVC], direction: .forward, animated: false)
    }
    // PageView Set up
    lazy var searchVC = SearchViewController()
    lazy var favoriteVC = FavoriteViewController()
    lazy var viewControllers = [self.searchVC, self.favoriteVC]
    lazy var pageView: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.delegate = self
        vc.dataSource = self
        return vc
    }()
    
    private func addView() {
        addChild(pageView)
        view.addSubview(pageView.view)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        setUpNavigationToolbar()
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
