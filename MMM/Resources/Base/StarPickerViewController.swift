//
//  StarViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/27.
//

import UIKit
import Then
import SnapKit
import Combine

class StarPickerViewController: UIViewController {
    // MARK: - UI Components
    private lazy var headerStackView = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var checkButton = UIButton()
    private lazy var satisfyingLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
    private lazy var starStackView = UIStackView()
    private lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48)
    ]
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    weak var delegate: BottomSheetChild?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }
}

// MARK: - Style & Layout & Bind
extension StarPickerViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        view.addSubviews(headerStackView, satisfyingLabel, starStackView)
        headerStackView.addSubviews(titleLabel, checkButton)
        
        headerStackView.addArrangedSubviews(titleLabel, checkButton)
        
        starList.forEach {
            $0.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview($0)
        }
        
        headerStackView = headerStackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalCentering
        }
        
        titleLabel = titleLabel.then {
            $0.text = "만족도 설정"
            $0.font = R.Font.h5
            $0.textColor = R.Color.black
            $0.textAlignment = .left
        }
        
        checkButton = checkButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(R.Color.gray500, for: .normal)
            $0.contentHorizontalAlignment = .right
            $0.titleLabel?.font = R.Font.title3
        }
        
        satisfyingLabel = satisfyingLabel.then {
            $0.text = "별점이 비어있어요"
            $0.backgroundColor = R.Color.gray700
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.textColor = R.Color.gray100
            $0.font = R.Font.body4
        }
        
        starStackView = starStackView.then {
            $0.axis = .horizontal
            $0.spacing = 23
            $0.distribution = .fillEqually
        }
    }
    
    private func setLayout() {
        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(28)
        }
        
        satisfyingLabel.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(satisfyingLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(52)
            $0.height.equalTo(48)
        }
    }
    
    // MARK: - Bind
    private func bind() {
        
    }
}
