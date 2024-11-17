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
        flowlayout.sectionHeadersPinToVisibleBounds = true
        flowlayout.sectionInset.top = 10.0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        cv.register(SearchCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchCollectionHeaderView.identifier)
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
    func needUpdateCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func addressSearching() {
        DispatchQueue.main.async { [weak self] in
            self?.addressSearchResultView.reloadData()
        }
    }
}
// MARK: -  SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filteringAddress(text: searchBar.text!)
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.filteredTripArray.count != 0{
            return CGSize(width: self.view.frame.width, height: 50)
        } else {
            return .zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchCollectionHeaderView.identifier, for: indexPath) as? SearchCollectionHeaderView else {
                return UICollectionReusableView()
            }
            if self.isSearching {
                header.defaultMode()
            }
            header.delegate = self
            return header
        case UICollectionView.elementKindSectionFooter:
            return UICollectionReusableView()
        default:
            print("Collection Header & Footer View load Fail")
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredTripArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(model: viewModel.filteredTripArray[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffY = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.contentSize.height
        let contentHeight = self.collectionView.frame.height
        let leftBottomHeight = scrollViewHeight - contentOffY - contentHeight
        let loadLine = scrollViewHeight * 0.1
        
        if leftBottomHeight <= loadLine {
            print("need more")
            viewModel.fetchData(isFirstLoad: false)
        }
        
    }
    
}
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width * 0.9
        return CGSize(width: width, height: 150)
    }
    
}

extension SearchViewController: SearchCollectionHeaderViewDelegate {
    func filteringButtonTapped(type: TripCategory) {
        collectionView.scrollToItem(at: IndexPath(item: -1, section: 0), at: .top, animated: false)
        viewModel.filteringTrip(type: type)
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
        cell.selectionStyle = .none
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

