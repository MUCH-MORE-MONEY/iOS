//
//  StatisticsCategoryView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import ReactorKit
import MarqueeLabel

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsCategoryView: BaseView, View {
	typealias Reactor = StatisticsReactor
	
	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 20
		static let barViewHeight: CGFloat = 8
		static let rankViewSide: CGFloat = 60
		static let categoryViewTop: CGFloat = 12
		static let moreLabelHeight: CGFloat = 18
		static let payLabelTop: CGFloat = 48
		static let payRankLabelTop: CGFloat = 44
		static let payBarViewTop: CGFloat = 68
		static let earnLabelTop: CGFloat = 96
		static let earnRankLabelTop: CGFloat = 92
		static let earnBarViewTop: CGFloat = 115
	}
	
	// MARK: - Properties

	// MARK: - UI Components
	private lazy var titleLabel = UILabel() 		// 카테고리
	private lazy var moreLabel = UILabel() 			// 더보기
	private lazy var payLabel = UILabel() 			// 지출
	private lazy var payRankLabel = MarqueeLabel() 	// 지출 랭킹
	private lazy var payBarView = UIView() 			// 지출 Bar
	private lazy var earnLabel = UILabel() 			// 수입
	private lazy var earnRankLabel = MarqueeLabel() // 수입 랭킹
	private lazy var earnBarView = UIView() 		// 수입 Bar
	
	func bind(reactor: StatisticsReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension StatisticsCategoryView {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsReactor) {
		// 카테고리 영역 클릭시, 화면전환
		self.rx.tapGesture()
			.when(.recognized) // 바인딩 할때 event emit 방지
			.map { _ in .didTapMoreButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsCategoryView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.black
		layer.cornerRadius = 10

		titleLabel = titleLabel.then {
			$0.text = "카테고리"
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
		}
		
		moreLabel = moreLabel.then {
			$0.text = "더보기"
			$0.font = R.Font.body4
			$0.textColor = R.Color.gray500
		}
		
		payLabel = payLabel.then {
			$0.text = "지출"
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
		}
		
		payRankLabel = payRankLabel.then {
			$0.text = "1위 보기만 해도 배부른  2위 쩝쩝 박사  3위 삶의 퀄리티"
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
			$0.type = .continuous
			$0.speed = .rate(50) // 숫자가 작을수록 느림
			$0.animationCurve = .linear
			$0.fadeLength = 44 // 얼마나 숨길지
			$0.animationDelay = 0
		}
		
		payBarView = payBarView.then {
			$0.layer.cornerRadius = 3
			$0.backgroundColor = R.Color.orange500
		}
		
		earnLabel = earnLabel.then {
			$0.text = "수입"
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
		}
		
		earnRankLabel = earnRankLabel.then {
			$0.text = "1위 먹고사는 식사  2위 내 미래에 투자  3위 개미의 웃음  4위 일상 탈출"
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
			$0.type = .continuous
			$0.speed = .rate(50) // 숫자가 작을수록 느림
			$0.animationCurve = .linear
			$0.fadeLength = 44 // 얼마나 숨길지
			$0.animationDelay = 0
		}
		
		earnBarView = earnBarView.then {
			$0.layer.cornerRadius = 3
			$0.backgroundColor = R.Color.blue600
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(titleLabel, moreLabel, payLabel, payRankLabel, payBarView, earnLabel, earnRankLabel, earnBarView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.categoryViewTop)
			$0.leading.equalToSuperview().inset(UI.sideMargin)
		}
		
		moreLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.categoryViewTop)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
			$0.height.equalTo(UI.moreLabelHeight)
		}
		
		payLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.payLabelTop)
			$0.leading.equalToSuperview().inset(UI.sideMargin)
		}
		
		payRankLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.payRankLabelTop)
			$0.leading.equalToSuperview().inset(UI.rankViewSide)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
		}
		
		payBarView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.payBarViewTop)
			$0.leading.equalToSuperview().inset(UI.rankViewSide)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
			$0.height.equalTo(UI.barViewHeight)
		}
		
		earnLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.earnLabelTop)
			$0.leading.equalToSuperview().inset(UI.sideMargin)
		}
		
		earnRankLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.earnRankLabelTop)
			$0.leading.equalToSuperview().inset(UI.rankViewSide)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
		}
		
		earnBarView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.earnBarViewTop)
			$0.leading.equalToSuperview().inset(UI.rankViewSide)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
			$0.height.equalTo(UI.barViewHeight)
		}
	}
}
