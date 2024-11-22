//
//  SearchTableViewCell.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/4/24.
//

import UIKit
import SnapKit

protocol SearchCollectionViewCellDelegate: AnyObject {
    func didTappedExpandButton(indexPath: IndexPath)
}
class SearchCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchCollectionViewCell"
    
    private var rankImageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    weak var delegate: SearchCollectionViewCellDelegate?
    
    var indexPath: IndexPath?
    
    private var relatedAreaLabel: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 20)
        lb.numberOfLines = 0
        return lb
    }()
    
    private var areaAddressLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "", size: 15)
        lb.textColor = .lightGray
        return lb
    }()
    
    private var favoriteButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        return btn
    }()
    
    private var contentStackView: UIStackView = {
    private lazy var expandButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("현재 날씨 보기", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        return btn
    }()
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        sv.alignment = .leading
        sv.distribution = .fillProportionally
        return sv
    }()
    
    private var rankAreaLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 5
        sv.alignment = .leading
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var categoryCollectionView = CategoryLabelsCollectionView(frame: .zero)
    
    @objc func expandButtonTapped() {
        guard let ip = indexPath else { return }
        delegate?.didTappedExpandButton(indexPath: ip)
    }
    private func configureCell() {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 3
        self.layer.cornerRadius = 10
    }
    
    private func addView() {
        rankAreaLabelStackView.addArrangedSubview(rankImageView)
        rankAreaLabelStackView.addArrangedSubview(relatedAreaLabel)
        contentStackView.addArrangedSubview(rankAreaLabelStackView)
        contentStackView.addArrangedSubview(areaCategoryLabel)
        contentStackView.addArrangedSubview(areaAddressLabel)
        contentStackView.addArrangedSubview(categoryCollectionView)
        contentView.addSubview(contentStackView)
        contentView.addSubview(favoriteButton)
    }
    
    private func configureLayout() {
        contentStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(15)
            make.bottom.trailing.equalToSuperview().offset(-15)
        }
        rankAreaLabelStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        categoryCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureCell()
        addView()
        configureLayout()
        self.backgroundColor = .white
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        self.rankImageView.image = nil
        self.rankImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(0)
        }
        categoryCollectionView.updateLabels(labels: [])
    }
    private func showRankImage() {
        rankImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(25)
        }
    }
    private func hideRankImage() {
        rankImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(0)
        }
    }
    func configure(model: TripItem) {
        self.areaAddressLabel.text = model.relatedAreaAddress
        self.areaCategoryLabel.text = "# \(model.relatedLargeCategoryName)   \(model.areaName)"
        let separatedRelatedAreaText = model.relatedAreaName.split(separator: "/").map{String($0)}
        if separatedRelatedAreaText.count == 1 {
            self.relatedAreaLabel.text = separatedRelatedAreaText.first
        } else {
            self.relatedAreaLabel.text = "\(separatedRelatedAreaText[0]) (\(separatedRelatedAreaText[1]))"
        }
        switch model.rankNum {
        case "1":
            self.rankImageView.image = UIImage(named: "firstPlaceRibbon")
            showRankImage()
        case "2":
            self.rankImageView.image = UIImage(named: "secondPlaceRibbon")
            showRankImage()
        case "3":
            self.rankImageView.image = UIImage(named: "thirdPlaceRibbon")
            showRankImage()
        default:
            self.rankImageView.image = nil
            hideRankImage()
        }
        
        let labels = Array(Set([model.relatedMediumCategoryName, model.relatedSmallCategoryName]))
        categoryCollectionView.updateLabels(labels: labels)
    }
}
