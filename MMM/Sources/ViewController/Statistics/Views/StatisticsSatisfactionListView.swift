//
//  StatisticsSatisfactionListView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/22.
//

import Then
import SnapKit
import ReactorKit
import RxGesture

final class StatisticsSatisfactionListView: UIView, View {
	// MARK: - Properties
	var disposeBag: DisposeBag = DisposeBag()
	
	// MARK: - UI Components
	private lazy var touchAreaView = UIView()
	private lazy var titleLabel = UILabel()
	private lazy var starImageView = UIImageView()
	private lazy var rangeLabel = UILabel()
	private lazy var arrowImageView = UIImageView()
	private lazy var tableView = UITableView()

	// Empty & Error UI
	private lazy var emptyView = HomeEmptyView()

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
extension StatisticsSatisfactionListView {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsReactor) {
		touchAreaView.rx.tapGesture()
			.when(.recognized) // 바인딩 할때 event emit 방지
			.map { _ in .didTapSatisfactionButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {}
}

//MARK: - Style & Layouts
private extension StatisticsSatisfactionListView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		backgroundColor = R.Color.gray100
		layer.cornerRadius = 10
		layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 왼쪽, 오른쪽 모서리에만 cornerRadius 적용

		touchAreaView = touchAreaView.then {
			$0.backgroundColor = R.Color.black
			$0.layer.cornerRadius = 10
		}
		
		titleLabel = titleLabel.then {
			$0.text = "아쉬운 활동 줄이기"
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
		}
		
		starImageView = starImageView.then {
			$0.image = R.Icon.iconStarOrange48
			$0.contentMode = .scaleAspectFit
		}
		
		rangeLabel = rangeLabel.then {
			$0.text = "1~2점"
			$0.font = R.Font.body2
			$0.textColor = R.Color.orange500
		}
		
		arrowImageView = arrowImageView.then {
			$0.image = R.Icon.arrowDown32
			$0.contentMode = .scaleAspectFit
		}
		
		tableView = tableView.then {
			$0.backgroundColor = R.Color.gray100
			$0.showsVerticalScrollIndicator = false
			$0.register(HomeTableViewCell.self)
			$0.separatorStyle = .none
			$0.isHidden = true
		}
		
		emptyView = emptyView.then {
			$0.isHidden = false
		}
	}
	
	private func setLayout() {
		addSubviews(touchAreaView, tableView, emptyView)
		touchAreaView.addSubviews(titleLabel, starImageView, rangeLabel, arrowImageView)
		
		touchAreaView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.height.equalTo(48)
		}
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(20)
		}
		
		starImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(titleLabel.snp.trailing).offset(11)
		}

		rangeLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(starImageView.snp.trailing).offset(4)
		}

		arrowImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.trailing.equalToSuperview().inset(12)
		}
		
		// Table View
		tableView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview()
			$0.top.equalTo(touchAreaView.snp.bottom)
		}
		
		emptyView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.top.equalTo(touchAreaView.snp.bottom)
			$0.height.equalTo(248)
		}
	}
}
