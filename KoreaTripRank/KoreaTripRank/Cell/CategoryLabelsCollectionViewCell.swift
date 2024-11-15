//
//  CategoryLabelsCollectionViewCell.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/16/24.
//

import UIKit
import SnapKit

class CategoryLabelsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CategoryLabelsCollectionViewCell"
    
    var titleCategoryLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = .boldSystemFont(ofSize: 15)
        lb.sizeToFit()
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .cyan
        contentView.addSubview(titleCategoryLabel)
        titleCategoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        self.clipsToBounds = false
        self.layer.cornerRadius = 10
    }
    override func prepareForReuse() {
        self.titleCategoryLabel.text = nil
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        self.titleCategoryLabel.text = text
    }
    
}
