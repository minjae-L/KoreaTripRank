//
//  ViewController.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/2/24.
//

import UIKit

class MainViewController: UIViewController {
    func setUpNavigationToolbar() {
        self.navigationController?.isToolbarHidden = false
        
        let appearance = UIToolbarAppearance()
        appearance.backgroundColor = .orange
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .done, target: self, action: #selector(favoriteButtonTapped))
        let mainViewButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .done, target: self, action: #selector(mainViewButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.navigationController?.toolbar.scrollEdgeAppearance = appearance
        let items = [space, mainViewButton, space, space, favoriteButton, space]
        self.toolbarItems = items
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpNavigationToolbar()
    }
    
    @objc func favoriteButtonTapped() {
        print("favoriteButton Tapped")
    }
    @objc func mainViewButtonTapped() {
        print("mainViewButton Tapped")
    }

}

