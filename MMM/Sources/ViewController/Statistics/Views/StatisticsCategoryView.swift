//
//  StatisticsCategoryView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import Then
import SnapKit
import ReactorKit
import MarqueeLabel

final class StatisticsCategoryView: UIView, View {
	typealias Reactor = StatisticsReactor
	
	// MARK: - Properties
	var disposeBag: DisposeBag = DisposeBag()

	// MARK: - UI Components
	private lazy var titleLabel = UILabel() 		// 카테고리
	private lazy var moreLabel = UILabel() 			// 더보기
	private lazy var payLabel = UILabel() 			// 지출
	private lazy var payRankLabel = MarqueeLabel() 	// 지출 랭킹
	private lazy var earnLabel = UILabel() 			// 수입
	private lazy var earnRankLabel = MarqueeLabel() // 수입 랭킹

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
	private func bindState(_ reactor: StatisticsReactor) {}
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
		
		moreLabel = moreLabel.then {
			$0.text = "더보기"
			$0.font = R.Font.body4
			$0.textColor = R.Color.gray500
		}
		
		payLabel = payLabel.then {
			$0.text = "지출"
			$0.font = R.Font.body2
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
		
		earnLabel = earnLabel.then {
			$0.text = "수입"
			$0.font = R.Font.body2
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
	}
	
	private func setLayout() {
		addSubviews(titleLabel, moreLabel, payLabel, payRankLabel, earnLabel, earnRankLabel)
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.leading.equalToSuperview().inset(20)
		}
		
		moreLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.trailing.equalToSuperview().inset(20)
			$0.height.equalTo(18)
		}
		
		payLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(48)
			$0.leading.equalToSuperview().inset(20)
		}
		
		payRankLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(44)
			$0.leading.equalToSuperview().inset(60)
			$0.trailing.equalToSuperview().inset(20)
		}
		
		earnLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(96)
			$0.leading.equalToSuperview().inset(20)
		}
		
		earnRankLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(92)
			$0.leading.equalToSuperview().inset(60)
			$0.trailing.equalToSuperview().inset(20)
		}
	}
}
