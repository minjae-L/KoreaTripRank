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
        lb.font = UIFont(name: "", size: 25)
        lb.textColor = .black
        return lb
    }()
    private func addView() {
        contentView.addSubview(areaLabel)
    }
    private func configureLayout() {
        areaLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(20)
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
    func configure(model: Int) {
        self.areaLabel.text = "\(model)"
    }

}
