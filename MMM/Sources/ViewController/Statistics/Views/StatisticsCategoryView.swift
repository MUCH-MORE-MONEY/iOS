//
//  StatisticsCategoryView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import Then
import SnapKit

final class StatisticsCategoryView: UIView {
	// MARK: - UI Components
	private lazy var titleLabel = UILabel() 		 // 카테고리
	private lazy var moreButton = UIButton() 		 // 더보기
	private lazy var payLabel = UILabel() 			 // 지출
	private lazy var payRankLabel = UILabel() 	 	 // 지출 랭킹
	private lazy var payBarImageView = UIImageView() // 지출바
	private lazy var earnLabel = UILabel() 			 // 수입
	private lazy var earnRankLabel = UILabel() 	 	 // 수입 랭킹

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
private extension StatisticsCategoryView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		backgroundColor = R.Color.black
		layer.cornerRadius = 10

		titleLabel = titleLabel.then {
			$0.text = "카테고리"
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
		}
		
		moreButton = moreButton.then {
			$0.setTitle("더보기", for: .normal)
			$0.setTitleColor(R.Color.gray500, for: .normal)
			$0.setTitleColor(R.Color.gray500.withAlphaComponent(0.7), for: .highlighted)
			$0.titleLabel?.font = R.Font.body4
		}
		
		payLabel = payLabel.then {
			$0.text = "지출"
			$0.font = R.Font.body4
			$0.textColor = R.Color.gray100
		}
		
		payRankLabel = payRankLabel.then {
			$0.text = "아직 지출 카테고리에 작성된 경제활동이 없어요"
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray500
		}
		
		earnLabel = earnLabel.then {
			$0.text = "수입"
			$0.font = R.Font.body4
			$0.textColor = R.Color.gray100
		}
		
		earnRankLabel = earnRankLabel.then {
			$0.text = "아직 수입 카테고리에 작성된 경제활동이 없어요"
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray500
		}
	}
	
	private func setLayout() {
		addSubviews(titleLabel, moreButton, payLabel, payRankLabel, payBarImageView, earnLabel, earnRankLabel)
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.leading.equalToSuperview().inset(20)
		}
		
		moreButton.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.trailing.equalToSuperview().inset(20)
			$0.height.equalTo(18)
		}
		
		payLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(14)
			$0.leading.equalToSuperview().inset(20)
		}
		
		payRankLabel.snp.makeConstraints {
			$0.centerY.equalTo(payLabel)
			$0.trailing.equalToSuperview().inset(20)
		}
		
		earnLabel.snp.makeConstraints {
			$0.top.equalTo(payLabel.snp.bottom).offset(14)
			$0.leading.equalToSuperview().inset(20)
		}
		
		earnRankLabel.snp.makeConstraints {
			$0.centerY.equalTo(earnLabel)
			$0.trailing.equalToSuperview().inset(20)
		}
	}
}
