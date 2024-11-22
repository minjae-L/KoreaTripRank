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
    
    // MARK: UI Property
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
    
    private lazy var weatherView: UIView = {
        let view = UIView()
        view.addSubview(self.expandButton)
        view.addSubview(self.weatherContentView)
        return view
    }()
    
    private lazy var expandButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("현재 날씨 보기", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let lb = UILabel()
        lb.sizeToFit()
        lb.font = .systemFont(ofSize: 15)
        lb.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(30)
        }
        return lb
    }()
    
    private lazy var rainAmountLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 15)
        lb.snp.makeConstraints { make in
            make.width.equalTo(0)
        }
        return lb
    }()
    
    private lazy var firstRainStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
        return imageView
    }()
    
    private lazy var secondRainStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.snp.makeConstraints { make in
            make.width.equalTo(0)
        }
        
        return imageView
    }()
    
    private lazy var skyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
        return imageView
    }()
    
    private lazy var windImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
        return imageView
    }()
    
    private lazy var windLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 15)
        lb.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(30)
        }
        return lb
    }()
    
    private lazy var weatherContentView: UIStackView = {
        let sb = UIStackView()
        sb.axis = .horizontal
        sb.spacing = 5
        sb.alignment = .center
        sb.distribution = .fill
        sb.addArrangedSubview(self.skyStateTemperatureContainerView)
        sb.addArrangedSubview(self.rainStateContainerView)
        sb.addArrangedSubview(self.windStateContainerView)
        sb.addArrangedSubview(self.emptyContainerView)
        return sb
    }()
    
    private lazy var skyStateTemperatureContainerView: UIView = {
        let view = UIView()
        view.addSubview(self.skyStateImageView)
        view.addSubview(self.temperatureLabel)
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowRadius = 3
        view.layer.cornerRadius = 10
        view.backgroundColor = .brown
        view.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(90)
        }
        return view
    }()
    
    private lazy var rainStateContainerView: UIView = {
        let view = UIView()
        view.addSubview(self.firstRainStateImageView)
        view.addSubview(self.secondRainStateImageView)
        view.addSubview(self.rainAmountLabel)
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowRadius = 3
        view.layer.cornerRadius = 10
        view.backgroundColor = .cyan
        view.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(130)
        }
        return view
    }()
    
    private lazy var windStateContainerView: UIView = {
        let view = UIView()
        view.addSubview(self.windImageView)
        view.addSubview(self.windLabel)
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowRadius = 3
        view.layer.cornerRadius = 10
        view.backgroundColor = .yellow
        view.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(90)
        }
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        sv.alignment = .leading
        sv.distribution = .fill
        sv.addArrangedSubview(self.rankAreaLabelStackView)
        sv.addArrangedSubview(self.areaAddressLabel)
        sv.addArrangedSubview(self.weatherView)
        sv.addArrangedSubview(self.categoryCollectionView)
        return sv
    }()
    
    private lazy var rankAreaLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 5
        sv.alignment = .leading
        sv.distribution = .fill
        sv.addArrangedSubview(self.rankImageView)
        sv.addArrangedSubview(self.relatedAreaLabel)
        return sv
    }()
    
    private lazy var emptyContainerView: UIView = {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.width.equalTo(0).priority(999)
        }
        return view
    }()
    
    private lazy var categoryCollectionView = CategoryLabelsCollectionView(frame: .zero)
    
    // MARK: Methods
    @objc func expandButtonTapped() {
        guard let ip = indexPath else { return }
        delegate?.didTappedExpandButton(indexPath: ip)
    }
    // 셀 그림자, 모양 정의
    private func configureCell() {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 3
        self.layer.cornerRadius = 10
    }
    
    private func addView() {
        contentView.addSubview(contentStackView)
        contentView.addSubview(favoriteButton)
    }
    // 확장된 경우 현재 날씨 레이아웃 설정
    private func weatherViewExpandedLayout() {
        [skyStateImageView, temperatureLabel, firstRainStateImageView, secondRainStateImageView, rainAmountLabel, windImageView, windLabel].forEach { view in
            if (view == secondRainStateImageView && secondRainStateImageView.image == nil) || (view == rainAmountLabel && rainAmountLabel.text == nil) {
                view.snp.updateConstraints { make in
                    make.width.equalTo(0)
                }
            } else {
                if view is UILabel {
                    view.snp.updateConstraints { make in
                        make.width.greaterThanOrEqualTo(30)
                    }
                } else {
                    view.snp.updateConstraints { make in
                        make.width.equalTo(30)
                    }
                }
            }
        }
        
        weatherContentView.snp.updateConstraints { make in
            make.height.equalTo(30)
        }
    }
    // 확장되지 않은 경우 레이아웃 설정 (기본값)
    private func weatherViewDefaultLayout() {
        
        weatherContentView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        self.skyStateImageView.image = nil
        self.temperatureLabel.text = nil
        self.firstRainStateImageView.image = nil
        self.secondRainStateImageView.image = nil
        self.rainAmountLabel.text = nil
        self.windLabel.text = nil
        self.windImageView.image = nil
    }
    // 처음 셀 불러오면 설정되는 레이아웃 (기본값)
    private func configureLayout() {
        contentStackView.snp.remakeConstraints { make in
            make.top.leading.equalToSuperview().offset(15)
            make.bottom.trailing.equalToSuperview().offset(-15)
        }
        areaAddressLabel.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        rankAreaLabelStackView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        categoryCollectionView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        favoriteButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
        weatherView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        expandButton.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        weatherContentView.snp.remakeConstraints { make in
            make.bottom.trailing.leading.equalToSuperview()
            make.height.equalTo(0)
        }
        [skyStateTemperatureContainerView, rainStateContainerView, windStateContainerView, emptyContainerView].forEach {
            $0.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
        }
        skyStateImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        temperatureLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(skyStateImageView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }
        firstRainStateImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        secondRainStateImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(firstRainStateImageView.snp.trailing).offset(5)
        }
        rainAmountLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(secondRainStateImageView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }
        windImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        windLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(windImageView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-5)
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
    // 재사용 시 셀안의 UI 상태 정의
    override func prepareForReuse() {
        isSelected = false
        self.rankImageView.image = nil
        self.rankImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(0)
        }
        categoryCollectionView.updateLabels(labels: [])
        self.skyStateImageView.image = nil
        self.firstRainStateImageView.image = nil
        self.secondRainStateImageView.image = nil
        self.windImageView.image = nil
        self.rainAmountLabel.text = nil
        self.temperatureLabel.text = nil
        self.windLabel.text = nil
        self.expandButton.setTitle("현재 날씨 보기", for: .normal)
    }
    // 순위 안에 있는 장소면 랭킹 보여주기
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
    // 커스텀 셀 UI 정의
    func configure(model: TripItem) {
        self.areaAddressLabel.text = model.relatedAreaAddress
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
        
        let labels = Array(Set([model.areaName, model.relatedLargeCategoryName, model.relatedMediumCategoryName, model.relatedSmallCategoryName])).sorted(by: <)
        categoryCollectionView.updateLabels(labels: labels)
        
    }
    // 확장 시 보여지는 WeaterView 정의
    func configureWeatherView(model: TripItem) {
        if !model.isExpanded {
            weatherViewDefaultLayout()
            self.expandButton.setTitle("현재 날씨 보기", for: .normal)
            return
        }
        guard let model = model.weatherModel else { return }

        self.expandButton.setTitle("닫기", for: .normal)
        self.weatherContentView.isHidden = false
        self.windImageView.image = UIImage(named: "wind")
        self.temperatureLabel.text = "\(model.temp)°C"
        self.windLabel.text = "\(model.wind)m/s"
        if model.rainAmount == "강수없음" {
            self.rainAmountLabel.text = nil
        } else {
            self.rainAmountLabel.text = "\(model.rainAmount)mm"
        }
        switch model.rainState {
        case "0":
            self.firstRainStateImageView.image = UIImage(named: "noRain")
            self.secondRainStateImageView.image = nil
        case "1":
            self.firstRainStateImageView.image = UIImage(named: "rain")
            self.secondRainStateImageView.image = nil
        case "2":
            self.firstRainStateImageView.image = UIImage(named: "rain")
            self.secondRainStateImageView.image = UIImage(named: "lightSnow")
        case "5":
            self.firstRainStateImageView.image = UIImage(named: "lightRain")
            self.secondRainStateImageView.image = nil
        case "6":
            self.firstRainStateImageView.image = UIImage(named: "lightRain")
            self.secondRainStateImageView.image = UIImage(named: "snow")
        case "7":
            self.firstRainStateImageView.image = UIImage(named: "snow")
            self.secondRainStateImageView.image = nil
        default:
            self.firstRainStateImageView.image = nil
            self.secondRainStateImageView.image = nil
        }
        switch model.skyState {
        case "1":
            self.skyStateImageView.image = UIImage(named: "sun")
        case "3":
            self.skyStateImageView.image = UIImage(named: "partlyCloudyDay")
        case "4":
            self.skyStateImageView.image = UIImage(named: "clouds")
        default:
            self.skyStateImageView.image = nil
        }
        weatherViewExpandedLayout()
    }
}
