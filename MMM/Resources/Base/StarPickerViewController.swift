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
import Cosmos

final class StarPickerViewController: UIViewController {
    // MARK: - UI Components
    private lazy var headerStackView = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var checkButton = UIButton()
    private lazy var satisfyingLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
    private lazy var cosmosView = CosmosView()
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    weak var delegate: BottomSheetChild?
    weak var starDelegate: StarPickerViewProtocol?
    // MARK: - Property Wrapper
    private var rating = 0.0
    
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
        bind()
    }
    
    private func setAttribute() {
        view.addSubviews(headerStackView, satisfyingLabel, cosmosView)
        
        headerStackView.addArrangedSubviews(titleLabel, checkButton)

        cosmosView = cosmosView.then {
            $0.settings.filledImage = R.Icon.iconStarBlack48
            $0.settings.emptyImage = R.Icon.iconStarGray48
            $0.settings.totalStars = 5
            $0.settings.starSize = 32
            $0.settings.starMargin = 23.08
            $0.settings.fillMode = .full
            $0.rating = rating
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
        
        cosmosView.snp.makeConstraints {
            $0.top.equalTo(satisfyingLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Bind
    private func bind() {
        checkButton.tapPublisher
            .sinkOnMainThread(receiveValue: willDismiss)
            .store(in: &cancellable)
        
        cosmosView.didTouchCosmos = { [weak self] in
            guard let self = self else { return }
            self.rating = $0
//            print("Rated: \(self.rating)")
            DispatchQueue.main.async {
                if self.rating != 0.0 {
                    self.checkButton.setTitleColor(R.Color.black, for: .normal)
                }
                self.satisfyingLabel.setSatisfyingLabelEdit(by: Int(self.rating))
            }
        }
    }
}

// MARK: - Action
extension StarPickerViewController {
    private func willDismiss() {
        if self.rating != 0.0 {
            delegate?.willDismiss()
            starDelegate?.willPickerDismiss(rating)
            print(rating)
        }
    }
}
