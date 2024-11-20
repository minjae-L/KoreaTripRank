//
//  CategoryLabelsCollectionView.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/16/24.
//

import UIKit
import SnapKit

class CategoryLabelsCollectionView: UIView {
    var categorys: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumInteritemSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryLabelsCollectionViewCell.self, forCellWithReuseIdentifier: CategoryLabelsCollectionViewCell.identifier)
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    func updateLabels(labels: [String]) {
        self.categorys = labels
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryLabelsCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryLabelsCollectionViewCell.identifier, for: indexPath) as? CategoryLabelsCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(text: categorys[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (categorys[indexPath.row] as NSString).size().width
        return CGSize(width: width + 25, height: self.frame.height)
    }
    
}
