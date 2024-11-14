//
//  SearchCollectionHeaderView.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/14/24.
//

import UIKit
import SnapKit

protocol SearchCollectionHeaderViewDelegate: AnyObject {
    func filteringButtonTapped(type: TripCategory)
}

class SearchCollectionHeaderView: UICollectionReusableView {
    
    static let identifier = "SearchCollectionHeaderView"
    weak var delegate: SearchCollectionHeaderViewDelegate?
    
    private lazy var allCategoryButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("전체", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitleColor(UIColor.white, for: .selected)
        btn.clipsToBounds = false
        btn.backgroundColor = .lightGray.withAlphaComponent(0.3)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(filteringButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var tourlistSpotButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("관광지", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitleColor(UIColor.white, for: .selected)
        btn.clipsToBounds = false
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .lightGray.withAlphaComponent(0.3)
        btn.addTarget(self, action: #selector(filteringButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var foodButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("음식", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitleColor(UIColor.white, for: .selected)
        btn.clipsToBounds = false
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .lightGray.withAlphaComponent(0.3)
        btn.addTarget(self, action: #selector(filteringButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var accommodationButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("숙박", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitleColor(UIColor.white, for: .selected)
        btn.clipsToBounds = false
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .lightGray.withAlphaComponent(0.3)
        btn.addTarget(self, action: #selector(filteringButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var buttonArray: [UIButton] = [allCategoryButton, tourlistSpotButton, foodButton, accommodationButton]
    
    private func selectedToggle(button: UIButton) {
        for btn in buttonArray {
            if btn == button {
                btn.isSelected = true
                btn.backgroundColor = .systemBlue
                continue
            }
            btn.isSelected = false
            btn.backgroundColor = .lightGray.withAlphaComponent(0.3)
        }
    }
    
    private func animateButton(button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = CGAffineTransform.identity
            }
        })
    }
    
    @objc private func filteringButtonTapped(button: UIButton) {
        self.animateButton(button: button)
        self.selectedToggle(button: button)
        switch button {
        case allCategoryButton:
            delegate?.filteringButtonTapped(type: .all)
        case tourlistSpotButton:
            delegate?.filteringButtonTapped(type: .tourristSpot)
        case foodButton:
            delegate?.filteringButtonTapped(type: .food)
        case accommodationButton:
            delegate?.filteringButtonTapped(type: .accommodation)
        default:
            print("error")
        }
    }
    
    func defaultMode() {
        for btn in buttonArray {
            btn.isSelected = false
            btn.backgroundColor = .lightGray.withAlphaComponent(0.3)
        }
        delegate?.filteringButtonTapped(type: .all)
    }
    private func addView() {
        addSubview(allCategoryButton)
        addSubview(tourlistSpotButton)
        addSubview(foodButton)
        addSubview(accommodationButton)
    }
    
    private func setLayout() {
        let allCateogoryButtonWidthSize: CGFloat = allCategoryButton.intrinsicContentSize.width + 15
        let tourlistSpotButtonWidthSize: CGFloat = tourlistSpotButton.intrinsicContentSize.width + 15
        let foodButtonWidthSize: CGFloat = foodButton.intrinsicContentSize.width + 15
        let accommodationButtonWidthSize: CGFloat = accommodationButton.intrinsicContentSize.width + 15
        
        allCategoryButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(allCateogoryButtonWidthSize)
        }
        tourlistSpotButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(allCategoryButton.snp.trailing).offset(10)
            make.width.equalTo(tourlistSpotButtonWidthSize)
        }
        foodButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(tourlistSpotButton.snp.trailing).offset(10)
            make.width.equalTo(foodButtonWidthSize)
        }
        accommodationButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(foodButton.snp.trailing).offset(10)
            make.width.equalTo(accommodationButtonWidthSize)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
