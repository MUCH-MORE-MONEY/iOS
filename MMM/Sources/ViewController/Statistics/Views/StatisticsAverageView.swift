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
			.map { .isSummary }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {
		// 요약하기
		reactor.state
			.map { $0.isSummary }
			.distinctUntilChanged() // 중복값 무시
			.withUnretained(self)
			.bind { (this, isSummary) in
				this.sumurryButton.setTitle(isSummary ? "요약보기" : "닫기", for: .normal)
			}.disposed(by: disposeBag)
	}
}

//MARK: - Action
extension StatisticsAverageView {
	// 외부에서 설정
	func setData(average: Double) {
		if average == 0.0 {
			starImageView.image = R.Icon.iconStarGray24
			titleLabel.text = "경제활동에 만족도를 설정해주세요"
			titleLabel.textColor = R.Color.gray700
			satisfactionLabel.text = "0 점"
			satisfactionLabel.textColor = R.Color.gray500
			sumurryButton.isHidden = true
		} else {
			starImageView.image = R.Icon.iconStarYellow24
			titleLabel.text = "경제활동 만족도"
			titleLabel.textColor = R.Color.gray200
			satisfactionLabel.text = "\(average) 점"
			satisfactionLabel.textColor = R.Color.white
			sumurryButton.isHidden = false
		}
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
			$0.textColor = R.Color.gray200
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
