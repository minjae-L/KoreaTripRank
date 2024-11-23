//
//  SearchViewController.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/3/24.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {
    
    // 뷰모델
    private lazy var viewModel: SearchViewModel = {
        let vm = SearchViewModel(locationSearcHandler: LocationSearch())
        vm.delegate = self
        return vm
    }()
    // 검색창으로 진입했는지 확인하기 위한 변수
    private var isSearching: Bool = false {
        didSet {
            if isSearching {
                searchingLayout()
            } else {
                defualtLayout()
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
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
        lb.text = "검색"
        lb.font = .boldSystemFont(ofSize: 20)
        lb.sizeToFit()
        return lb
    }()
    
    private lazy var searchContainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.addSubview(self.titleLabel)
        view.addSubview(self.searchButton)
        view.addSubview(self.searchBar)
        view.addSubview(self.addressSearchResultView)
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
    }
    // 기본모드일 때 레이아웃
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
    // 검색모드일 때 레이아웃
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        defualtLayout()
    }
    // 검색 버튼 이벤트
    @objc func searchButtonTapped() {
        searchBar.showsCancelButton = true
        self.isSearching = true
    }
    
}

// ViewModel Delegate
extension SearchViewController: SearchViewModelDelegate {
    // 무한스크롤 또는 필터링된 데이터를 보여줄 때 다시 불러오기
    func needUpdateCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    // 주소검색에서 자동완성을 위한 다시 불러오기
    func addressSearching() {
        DispatchQueue.main.async { [weak self] in
            self?.addressSearchResultView.reloadData()
        }
    }
}
//MARK: - CollectionViewButtonDelegate
extension SearchViewController: SearchCollectionViewCellDelegate {
    // 현재 날씨 보기 클릭 시 셀 높이가 확장되며 현재 날씨를 표시하고 해당 셀의 isExpaned 데이터 수정
    func didTappedExpandButton(indexPath: IndexPath) {
        viewModel.filteredTripArray[indexPath.row].isExpanded.toggle()
        viewModel.checkCoordinate(index: indexPath.row)
        // 애니메이션 실행 후 다시불러오기
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.collectionView.reloadItems(at: [indexPath])
        } completion: { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}

// MARK: -  SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    // 주소검색 자동완성
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filteringAddress(text: searchBar.text!)
    }
    // 검색버튼 클릭 시 해당 주소의 관광지 불러오기
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
        // 검색된 데이터가 있는 경우 헤더 보이기
        if viewModel.filteredTripArray.count != 0{
            return CGSize(width: self.view.frame.width, height: 50)
        } else {
            return .zero
        }
    }
    // 헤더 정의
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
        // 셀 버튼 이벤트를 위한 델리게이트 선언
        cell.delegate = self
        cell.configure(model: viewModel.filteredTripArray[indexPath.row])
        cell.indexPath = indexPath
        return cell
    }
    // 일정 이하로 스크롤 시 데이터 추가로 불러오기 위해 현재 위치 값을 구하고 조건과 비교하기
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isSearching else { return }
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
// MARK: UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    // 셀 높이 정의
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width * 0.9
        if viewModel.filteredTripArray[indexPath.row].isExpanded {
            return CGSize(width: width, height: 180)
        } else {
            return CGSize(width: width, height: 150)
        }
    }
    
}
// 헤더 뷰에 있는 카테고리 선택 시 해당 아이템 보여주기
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
        viewModel.selectedSigungu = viewModel.filteredAddressArray[indexPath.row]
        viewModel.fetchData(isFirstLoad: true)
    }
}


