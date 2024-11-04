//
//  SearchViewController.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/3/24.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {
    
    lazy private var viewModel: SearchViewModel = {
        let vm = SearchViewModel()
        vm.delegate = self
        return vm
    }()
    
    //MARK: UI Property
    lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        return cv
    }()
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        return sb
    }()
    lazy var searchContainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        return view
    }()
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return btn
    }()
    lazy var addressSearchResultView: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.isHidden = true
        tb.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        tb.register(AddressSearchResultTableViewCell.self, forCellReuseIdentifier: AddressSearchResultTableViewCell.identifier)
        return tb
    }()
    private func addView() {
        view.addSubview(collectionView)
        view.addSubview(searchContainView)
//        searchContainVew.addSubview(searchButton)
        searchContainView.addSubview(searchBar)
        searchContainView.addSubview(addressSearchResultView)

    }
    private func configureLayout() {
        searchContainView.snp.makeConstraints { make in
            make.top.equalTo(self.view.layoutMarginsGuide)
            make.trailing.leading.equalTo(self.view)
            make.height.equalTo(50)
        }
        searchBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.searchContainView)
            make.height.equalTo(50)
        }
        collectionView.snp.makeConstraints { make in
            make.trailing.leading.equalTo(self.view)
            make.bottom.equalTo(self.view.layoutMarginsGuide)
            make.top.equalTo(self.view.layoutMarginsGuide).offset(50)
        }
        
    }
    private func normalLayouot() {
        addressSearchResultView.isHidden = true
        searchContainView.snp.updateConstraints { make in
            make.height.equalTo(50)
        }
        searchBar.snp.updateConstraints { make in
            make.top.leading.trailing.equalTo(self.searchContainView)
            make.height.equalTo(50)
        }
    }
    private func searchingLayout() {
        addressSearchResultView.isHidden = false
        searchContainView.snp.updateConstraints { make in
            make.height.equalTo(self.view.frame.height)
        }
        searchBar.snp.updateConstraints { make in
            make.top.equalTo(self.searchContainView.snp.top)
            make.leading.trailing.equalTo(self.searchContainView)
            make.height.equalTo(50)
        }
        addressSearchResultView.snp.updateConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.leading.trailing.equalTo(searchContainView)
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        configureLayout()
    }
    @objc func searchButtonTapped() {
        print(#function)
    }
    
}

extension SearchViewController: SearchViewModelDelegate {
    func addressSearching() {
        print("addressSearching")
        DispatchQueue.main.async { [weak self] in
            self?.addressSearchResultView.reloadData()
        }
    }
    
    
}
// MARK: -  SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchingLayout()
        searchBar.showsCancelButton = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchingLayout()
        searchBar.showsCancelButton = true
        viewModel.filtering(text: searchBar.text!)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        normalLayouot()
        searchBar.showsCancelButton = false
    }
}

// MARK: - CollectionViewDelegate, DataSource, DelegateFlowLayout
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        cell.areaLabel.text = "\(indexPath.row)"
        cell.areaDetailLabel.text = "서울특별시 관악구"
        return cell
    }
}
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 200)
    }
}

// MARK: - TableView Delegate, DataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredAddressArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddressSearchResultTableViewCell.identifier, for: indexPath) as? AddressSearchResultTableViewCell else { return UITableViewCell() }
        
        
        cell.configure(model: viewModel.filteredAddressArray[indexPath.row])
        
        return cell
    }
}



