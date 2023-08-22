//
//  StatisticsActivityView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/22.
//

import Then
import SnapKit

final class StatisticsActivityView: UIView {
	// MARK: - UI Components
	private lazy var stackView = UIStackView()
	private lazy var satisfactionView = UIView()	// 만족스러운 활동 영역
	private lazy var satisfactionLabel = UILabel()	// 만족스러운 활동
	private lazy var satisfactionImageView = UIImageView()	// ✨
	private lazy var satisfactionTitleLabel = UILabel()
	private lazy var satisfactionPriceLabel = UILabel()

	private lazy var disappointingView = UIView()			// 아쉬운 활동 영역
	private lazy var disappointingLabel = UILabel()			// 아쉬운 활동
	private lazy var disappointingImageView = UIImageView() // 💦
	private lazy var disappointingTitleLabel = UILabel()
	private lazy var disappointingPriceLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Style & Layouts
private extension StatisticsActivityView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		backgroundColor = R.Color.black
		layer.cornerRadius = 10
		
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.spacing = 12
			$0.distribution = .fillProportionally
		}
		
		satisfactionLabel = satisfactionLabel.then {
			$0.text = "만족스러운 활동"
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray200
		}
		
		disappointingLabel = disappointingLabel.then {
			$0.text = "아쉬운 활동"
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray200
		}
		
		satisfactionImageView = satisfactionImageView.then {
			$0.image = R.Icon.star
			$0.contentMode = .scaleAspectFit
		}
		
		disappointingImageView = disappointingImageView.then {
			$0.image = R.Icon.rain
			$0.contentMode = .scaleAspectFit
		}
		
		satisfactionTitleLabel = satisfactionTitleLabel.then {
			$0.text = "아직 활동이 없어요"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray600
		}
		
		disappointingTitleLabel = disappointingTitleLabel.then {
			$0.text = "아직 활동이 없어요"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray600
		}
		
		satisfactionPriceLabel = satisfactionPriceLabel.then {
			$0.text = "만족한 활동을 적어주세요"
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray800
		}
		
		disappointingPriceLabel = disappointingPriceLabel.then {
			$0.text = "아쉬운 활동을 적어주세요"
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray800
		}
	}
	
	private func setLayout() {
		addSubview(stackView)
		stackView.addArrangedSubviews(satisfactionView, disappointingView)
		satisfactionView.addSubviews(satisfactionLabel, satisfactionImageView, satisfactionTitleLabel, satisfactionPriceLabel)
		disappointingView.addSubviews(disappointingLabel, disappointingImageView, disappointingTitleLabel, disappointingPriceLabel)
		
		stackView.snp.makeConstraints {
			$0.top.bottom.equalToSuperview().inset(12)
			$0.leading.trailing.equalToSuperview().inset(20)
		}
		
		satisfactionLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		disappointingLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		satisfactionImageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalTo(satisfactionLabel.snp.trailing).offset(2)
		}
		
		disappointingImageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalTo(disappointingLabel.snp.trailing).offset(2)
		}
		
		satisfactionTitleLabel.snp.makeConstraints {
			$0.bottom.equalTo(disappointingPriceLabel.snp.top).offset(-8)
			$0.leading.equalToSuperview()
		}
		
		disappointingTitleLabel.snp.makeConstraints {
			$0.bottom.equalTo(disappointingPriceLabel.snp.top).offset(-8)
			$0.leading.equalToSuperview()
		}
		
		satisfactionPriceLabel.snp.makeConstraints {
			$0.leading.bottom.equalToSuperview()
		}
		
		disappointingPriceLabel.snp.makeConstraints {
			$0.leading.bottom.equalToSuperview()
		}
	}
}
