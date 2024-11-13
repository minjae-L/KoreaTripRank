//
//  SearchViewController.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/3/24.
//

import UIKit
import SnapKit
import MapKit

class SearchViewController: UIViewController {
    
    private lazy var viewModel: SearchViewModel = {
        let vm = SearchViewModel()
        vm.delegate = self
        return vm
    }()
    private var isSearching: Bool = false {
        didSet {
            if isSearching {
                searchingLayout()
            } else {
                defualtLayout()
            }
            changedLayout()
        }
    }
    //MARK: UI Property
    private lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        return cv
    }()
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        sb.delegate = self
        return sb
    }()
    private var titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "한국 관광지 랭킹"
        lb.font = .boldSystemFont(ofSize: 20)
        lb.sizeToFit()
        return lb
    }()
    private lazy var searchContainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view
    }()
    private lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        btn.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return btn
    }()
    private lazy var addressSearchResultView: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        tb.register(AddressSearchResultTableViewCell.self, forCellReuseIdentifier: AddressSearchResultTableViewCell.identifier)
        return tb
    }()
    private func addView() {
        view.addSubview(collectionView)
        view.addSubview(searchContainView)
        searchContainView.addSubview(titleLabel)
        searchContainView.addSubview(searchButton)
        searchContainView.addSubview(searchBar)
        searchContainView.addSubview(addressSearchResultView)
    }
    private func defualtLayout() {
        self.titleLabel.isHidden = false
        self.searchButton.isHidden = false
        titleLabel.snp.remakeConstraints { make in
            make.centerX.equalTo(self.searchContainView)
            make.top.equalToSuperview().offset(10)
        }
        searchContainView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.layoutMarginsGuide)
            make.trailing.leading.equalToSuperview()
            make.height.equalTo(50)
        }
        searchButton.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        searchBar.snp.remakeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalTo(0)
        }
        collectionView.snp.remakeConstraints { make in
            make.bottom.trailing.leading.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        addressSearchResultView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    private func searchingLayout() {
        self.titleLabel.isHidden = true
        self.searchButton.isHidden = true
        searchContainView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.layoutMarginsGuide)
            make.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        searchBar.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        addressSearchResultView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
    }
    private func changedLayout() {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        defualtLayout()
    }
    @objc func searchButtonTapped() {
        searchBar.showsCancelButton = true
        self.isSearching = true
    }
    
}

extension SearchViewController: SearchViewModelDelegate {
    func addressSearching() {
        DispatchQueue.main.async { [weak self] in
            self?.addressSearchResultView.reloadData()
        }
    }
}
// MARK: -  SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filtering(text: searchBar.text!)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.isSearching = false
        viewModel.filteredAddressArray.removeAll()
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
}

// MARK: - CollectionViewDelegate, DataSource, DelegateFlowLayout
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(model: indexPath.row)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(viewModel.filteredAddressArray[indexPath.row])
        let searchText = "\(viewModel.filteredAddressArray[indexPath.row].areaName) \(viewModel.filteredAddressArray[indexPath.row].sigunguName)"
        viewModel.completer.delegate = self
        viewModel.didSected(text: searchText, index: indexPath.row)
    }
}

extension SearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("delegate")
        print(completer.results)
        viewModel.getLocation(results: completer.results)
    }
}
