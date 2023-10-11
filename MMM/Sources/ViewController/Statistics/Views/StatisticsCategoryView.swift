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
	private lazy var alphaList: [CGFloat] = [1, 0.8, 0.5, 0.3, 0.2]
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel() 		// 카테고리
	private lazy var moreLabel = UILabel() 			// 더보기
	private lazy var payLabel = UILabel() 			// 지출
	private lazy var payRankLabel = MarqueeLabel() 	// 지출 랭킹
	private lazy var payBarView = UIView() 			// 지출 Bar
	private lazy var payEmptyLabel = UILabel() 		// 지출 Empty
	
	private lazy var earnLabel = UILabel() 			// 수입
	private lazy var earnRankLabel = MarqueeLabel() // 수입 랭킹
	private lazy var earnBarView = UIView() 		// 수입 Bar
	private lazy var earnEmptyLabel = UILabel() 	// 수입 Empty

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
	private func bindState(_ reactor: StatisticsReactor) {
		reactor.state
			.map { $0.payBarList }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: { self.convertData($0, "01")})
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.earnBarList }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: { self.convertData($0, "02")})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension StatisticsCategoryView {
	func convertData(_ data: [CategoryBar], _ type: String) {
		let isEmpty = data.isEmpty

		if type == "01" {
			payEmptyLabel.isHidden = !isEmpty
			payRankLabel.isHidden = isEmpty
			payBarView.isHidden = isEmpty
			payRankLabel.text = data.enumerated().map { "\($0.offset + 1)위 \($0.element.title)"}.joined(separator: "  ")
		} else {
			earnEmptyLabel.isHidden = !isEmpty
			earnRankLabel.isHidden = isEmpty
			earnBarView.isHidden = isEmpty
			earnRankLabel.text = data.enumerated().map { "\($0.offset + 1)위 \($0.element.title)"}.joined(separator: "  ")
		}
		convertBar(data, type)
	}
	
	func convertBar(_ data: [CategoryBar], _ type: String) {
		guard !data.isEmpty else { return }

		var bounds = UIScreen.width
		let totalWidth = bounds - UI.rankViewSide - UI.sideMargin - 20 * 2 // 전체 Bar 길이
		let unit = totalWidth / 100.0
		var sumWidth = 0.0
		let cnt = data.count
		let barView: UIView = type == "01" ? payBarView : earnBarView
		barView.subviews.forEach { $0.removeFromSuperview() } // 기존에 있던 subView 제거
		let color: UIColor = type == "01" ? R.Color.orange500 : R.Color.blue500
		let minimumWidth = 2.0
		let spacing = 2.0
		
		// 2씩 빼는 이유는 spacing
		for (index, info) in data.map({ floor($0.ratio * unit) - spacing }).enumerated() {
			let isSmall = info < minimumWidth
			let width = cnt == 1 ? totalWidth : isSmall ? minimumWidth : info
			let view = UIView()
			view.layer.cornerRadius = isSmall ? 1 : 2.61
			view.backgroundColor = color.withAlphaComponent(alphaList[index])
			
			barView.addSubview(view)
			
			view.snp.makeConstraints {
				$0.centerY.equalToSuperview()
				$0.width.equalTo(width)
				$0.leading.equalToSuperview().inset(sumWidth)
				$0.height.equalTo(UI.barViewHeight)
			}
			
			sumWidth += width + spacing
		}
	}
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
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
			$0.type = .continuous
			$0.speed = .rate(50) // 숫자가 작을수록 느림
			$0.animationCurve = .linear
			$0.fadeLength = 44 // 얼마나 숨길지
			$0.animationDelay = 0
			$0.isHidden = true
		}
		
		payBarView = payBarView.then {
			$0.layer.cornerRadius = 3
			$0.isHidden = true
		}
		
		payEmptyLabel = payEmptyLabel.then {
			$0.text = "아직 카테고리에 작성된 경제활동이 없어요"
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray700
			$0.textAlignment = .center
		}
		
		earnLabel = earnLabel.then {
			$0.text = "수입"
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
		}
		
		earnRankLabel = earnRankLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
			$0.type = .continuous
			$0.speed = .rate(50) // 숫자가 작을수록 느림
			$0.animationCurve = .linear
			$0.fadeLength = 44 // 얼마나 숨길지
			$0.animationDelay = 0
			$0.isHidden = true
		}
		
		earnBarView = earnBarView.then {
			$0.layer.cornerRadius = 3
			$0.isHidden = true
		}
		
		earnEmptyLabel = earnEmptyLabel.then {
			$0.text = "아직 카테고리에 작성된 경제활동이 없어요"
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray700
			$0.textAlignment = .center
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(titleLabel, moreLabel, payLabel, payRankLabel, payBarView, payEmptyLabel, earnLabel, earnRankLabel, earnBarView, earnEmptyLabel)
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
		
		payEmptyLabel.snp.makeConstraints {
			$0.leading.equalTo(payLabel.snp.trailing).offset(12)
			$0.trailing.equalToSuperview().inset(20)
			$0.centerY.equalTo(payLabel)
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
		
		earnEmptyLabel.snp.makeConstraints {
			$0.leading.equalTo(earnLabel.snp.trailing).offset(12)
			$0.trailing.equalToSuperview().inset(20)
			$0.centerY.equalTo(earnLabel)
		}
	}
}
