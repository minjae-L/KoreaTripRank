//
//  SearchViewController.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/3/24.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {

    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        return sb
    }()
    
    private func addView() {
        view.addSubview(searchBar)
    }
    private func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.layoutMarginsGuide)
            make.leading.trailing.equalTo(self.view)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        addView()
        configureLayout()
    }
}

extension SearchViewController: UISearchBarDelegate {
    
}
