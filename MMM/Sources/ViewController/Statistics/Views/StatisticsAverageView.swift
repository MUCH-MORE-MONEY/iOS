//
//  StatisticsAverageView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsAverageView: BaseView, View {
	typealias Reactor = StatisticsReactor

	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 20
		static let starLeading: CGFloat = 4
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel() // 이번 달 경제활동 만족도
	private lazy var satisfactionLabel = UILabel()
	private lazy var starImageView = UIImageView() // ⭐️
	private lazy var sumurryButton = UIButton() // 요약보기
	
	func bind(reactor: StatisticsReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension StatisticsAverageView {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsReactor) {
		// 요약보기/닫기
		sumurryButton.rx.tap
			.withUnretained(self)
			.subscribe(onNext: { this, _ in
				this.sumurryButton.isSelected.toggle()
				
				// 요약하기
				if this.sumurryButton.isSelected {
					this.sumurryButton.setTitle("요약보기", for: .normal)
				} else { // 닫기
					this.sumurryButton.setTitle("닫기", for: .normal)
				}
			}).disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {
	}
}

//MARK: - Action
extension StatisticsAverageView {
	// 외부에서 설정
	func setData(average: Double) {
		let floor = floor(average) // 소수점 버림
		satisfactionLabel.text = floor == average ? "\(Int(floor)) 점" : "\(average) 점"
	}
	
	func isLoading(_ isLoading: Bool) {
		titleLabel.isHidden = isLoading
		satisfactionLabel.isHidden = isLoading
		starImageView.isHidden = isLoading
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsAverageView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.black
		layer.cornerRadius = 10
		
		starImageView = starImageView.then {
			$0.image = R.Icon.iconStarYellow24
			$0.contentMode = .scaleAspectFit
		}
		
		satisfactionLabel = satisfactionLabel.then {
			$0.text = "0.0점"
			$0.font = R.Font.prtendard(family: .bold, size: 18)
			$0.textColor = R.Color.white
		}
		
		titleLabel = titleLabel.then {
			$0.text = "경제활동 만족도"
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
		}
		
		sumurryButton = sumurryButton.then {
			$0.setTitle("요약보기", for: .normal)
			$0.setTitleColor(R.Color.gray500, for: .normal)
			$0.titleLabel?.font = R.Font.body4
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(starImageView, satisfactionLabel, titleLabel, sumurryButton)
	}
	
	override func setLayout() {
		super.setLayout()
		
		starImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(UI.sideMargin)
		}
		
		satisfactionLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(starImageView.snp.trailing).offset(8)
		}
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(satisfactionLabel.snp.trailing).offset(8)
		}
		
		sumurryButton.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.height.equalToSuperview()
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
		}
	}
}
