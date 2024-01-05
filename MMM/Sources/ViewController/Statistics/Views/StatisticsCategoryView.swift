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
	private lazy var barWidth: CGFloat = UIScreen.width - UI.rankViewSide - UI.sideMargin - 20 * 2 // 전체 Bar 길이

	// MARK: - UI Components
	private lazy var titleLabel = UILabel() 		 // 카테고리
	private lazy var moreLabel = UILabel() 			 // 더보기
	private lazy var payLabel = UILabel() 			 // 지출
	private lazy var payRankLabel = MarqueeLabel() 	 // 지출 랭킹
	private lazy var payBarStackView = UIStackView() // 지출 Bar
	private lazy var payEmptyLabel = UILabel() 		 // 지출 Empty
	
	private lazy var earnLabel = UILabel() 			 // 수입
	private lazy var earnRankLabel = MarqueeLabel()  // 수입 랭킹
	private lazy var earnBarStackView = UIStackView()// 지출 Bar
	private lazy var earnEmptyLabel = UILabel() 	 // 수입 Empty

	// 스켈레톤 UI
	private lazy var payView = UIView()
	private lazy var payLayer = CAGradientLayer()
	private lazy var payBarView = UIView()
	private lazy var payBarLayer = CAGradientLayer()

	private lazy var earnView = UIView()
	private lazy var earnLayer = CAGradientLayer()
	private lazy var earnBarView = UIView()
	private lazy var earnBarLayer = CAGradientLayer()

	override func layoutSubviews() {
		super.layoutSubviews()
		
		payLayer.frame = payView.bounds
		payLayer.cornerRadius = 4
		
		payBarLayer.frame = payBarView.bounds
		payBarLayer.cornerRadius = 4
		
		earnLayer.frame = earnView.bounds
		earnLayer.cornerRadius = 4
		
		earnBarLayer.frame = earnBarView.bounds
		earnBarLayer.cornerRadius = 4
	}
	
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
		let str = data.enumerated().map { "\($0.offset + 1)위 \($0.element.title)"}.joined(separator: "  " )
		
		if type == "01" {
			payEmptyLabel.isHidden = !isEmpty
			payRankLabel.isHidden = isEmpty
			payBarStackView.isHidden = isEmpty
			payRankLabel.text = str
		} else {
			earnEmptyLabel.isHidden = !isEmpty
			earnRankLabel.isHidden = isEmpty
			earnBarStackView.isHidden = isEmpty
			earnRankLabel.text = str
		}
		
		convertBar(data, type)
	}
	
	func isLoading(_ isLoading: Bool) {
		titleLabel.isHidden = isLoading
		moreLabel.isHidden = isLoading
		
		payView.isHidden = !isLoading
		payBarView.isHidden = !isLoading
		earnView.isHidden = !isLoading
		earnBarView.isHidden = !isLoading
	}
	
	func convertBar(_ data: [CategoryBar], _ type: String) {
		guard !data.isEmpty else { return }

		let unit = barWidth / 100.0
		let cnt = data.count
		let barView: UIStackView = type == "01" ? payBarStackView : earnBarStackView
		barView.subviews.forEach { $0.removeFromSuperview() } // 기존에 있던 subView 제거
		let color: UIColor = type == "01" ? R.Color.orange500 : R.Color.blue500
		let minimumWidth = 3.0
		var sumSmail = 0
		var flag = true
		
		for (index, info) in data.map({ floor($0.ratio * unit) }).enumerated().reversed() {
			let isSmall = info < minimumWidth
			flag = flag || isSmall
			var width = cnt == 1 ? barWidth : isSmall ? minimumWidth : info
			let view = UIView()
			view.layer.cornerRadius = data[index].ratio < 2.0 ? 1.7 : 2.61
			view.backgroundColor = color.withAlphaComponent(alphaList[index >= 4 ? 4 : index]) // 범위를 넘어갈 경우
						
			barView.insertArrangedSubview(view, at: 0)

			sumSmail += isSmall ? 1 : 0

			if flag != isSmall {
				width -= Double(sumSmail) * minimumWidth
			}
			
			view.snp.makeConstraints {
				$0.width.equalTo(width)
			}
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsCategoryView: SkeletonLoadable {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.black
		layer.cornerRadius = 10

		let firstGroup = makeAnimationGroup(startColor: R.Color.gray900, endColor: R.Color.gray700)
		firstGroup.beginTime = 0.0
		let secondGroup = makeAnimationGroup(previousGroup: firstGroup, startColor: R.Color.gray900, endColor: R.Color.gray700)

		payLayer = payLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(firstGroup, forKey: "backgroundColor")
		}
		
		earnLayer = earnLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(firstGroup, forKey: "backgroundColor")
		}
		
		payView = payView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: 28, height: 24))
			$0.layer.addSublayer(payLayer)
		}
		
		earnView = earnView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: 28, height: 24))
			$0.layer.addSublayer(earnLayer)
		}
		
		let width = UIScreen.width
		payBarView = payBarView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: width - 80 - 41, height: 20))
			$0.layer.addSublayer(payBarLayer)
		}
		
		earnBarView = earnBarView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: width - 80 - 41, height: 20))
			$0.layer.addSublayer(earnBarLayer)
		}
		
		payBarLayer = payBarLayer.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
		
		earnBarLayer = earnBarLayer.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
				
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
		
		payBarStackView = payBarStackView.then {
			$0.axis = .horizontal
			$0.spacing = 2
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
		
		earnBarStackView = earnBarStackView.then {
			$0.axis = .horizontal
			$0.spacing = 2
			$0.isHidden = true
			$0.distribution = .equalSpacing
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
		
		addSubviews(titleLabel, moreLabel, payLabel, payRankLabel, payBarStackView, payEmptyLabel, earnLabel, earnRankLabel, earnBarStackView, earnEmptyLabel, payView, earnView, payBarView, earnBarView)
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
		
		payBarStackView.snp.makeConstraints {
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
		
		earnBarStackView.snp.makeConstraints {
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
		
		// 스켈레톤 Layer
		payView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(48)
			$0.leading.equalToSuperview().inset(20)
			$0.width.equalTo(28)
			$0.height.equalTo(24)
		}
		
		earnView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(96)
			$0.leading.equalToSuperview().inset(20)
			$0.width.equalTo(28)
			$0.height.equalTo(24)
		}
		
		let width = UIScreen.width
		payBarView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(48)
			$0.leading.equalToSuperview().inset(60)
			$0.width.equalTo(width - 80 - 41)
			$0.height.equalTo(20)
		}
		
		earnBarView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(96)
			$0.leading.equalToSuperview().inset(60)
			$0.width.equalTo(width - 80 - 41)
			$0.height.equalTo(20)
		}
	}
}
