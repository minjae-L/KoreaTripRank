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
    
    var areaLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "", size: 25)
        lb.textColor = .black
        return lb
    }()
    var areaDetailLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "", size: 15)
        lb.textColor = .lightGray
        return lb
    }()
    private func addView() {
        contentView.addSubview(areaLabel)
        contentView.addSubview(areaDetailLabel)
    }
    private func configureLayout() {
        areaLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(20)
        }
        areaDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(areaLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(10)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addView()
        configureLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
