//
//  SearchResultTableViewCell.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/4/24.
//

import UIKit
import SnapKit

class AddressSearchResultTableViewCell: UITableViewCell {
    static let identifier = "AddressSearchResultTableViewCell"
    private var areaLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "", size: 25)
        lb.textColor = .black
        return lb
    }()
    private var areaDetailLabel: UILabel = {
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: LocationDataModel) {
        self.areaLabel.text = model.sigunguName
        self.areaDetailLabel.text = "\(model.areaName) \(model.sigunguName)"
    }
}
