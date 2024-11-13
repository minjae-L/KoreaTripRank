//
//  SearchTableViewCell.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/4/24.
//

import UIKit
import SnapKit

class SearchCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchCollectionViewCell"
    
    private var areaLabel: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 20)
        return lb
    }()
    private var relatedAreaLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "", size: 35)
        return lb
    }()
    
    private var areaAddressLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "", size: 15)
        lb.textColor = .lightGray
        return lb
    }()
    
    private var relatedCategoryLabel: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 20)
        return lb
    }()
    
    private var favoriteButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        return btn
    }()
    
    private func addView() {
        contentView.addSubview(areaLabel)
        contentView.addSubview(relatedAreaLabel)
        contentView.addSubview(areaAddressLabel)
        contentView.addSubview(relatedCategoryLabel)
        contentView.addSubview(favoriteButton)
    }
    private func configureLayout() {
        relatedCategoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        areaLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(relatedCategoryLabel.snp.trailing).offset(10)
        }
        relatedAreaLabel.snp.makeConstraints { make in
            make.top.equalTo(areaLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
        }
        areaAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(relatedAreaLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addView()
        configureLayout()
        self.backgroundColor = .white
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(model: TripItem) {
        self.areaLabel.text = model.areaName
        self.areaAddressLabel.text = model.relatedAreaAddress
        self.relatedAreaLabel.text = model.relatedAreaName
        self.relatedCategoryLabel.text = "[\(model.relatedLargeCategoryName)]"
    }

}
