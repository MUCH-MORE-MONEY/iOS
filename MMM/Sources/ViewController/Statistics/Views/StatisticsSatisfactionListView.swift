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

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsSatisfactionListView: BaseView, View {
	typealias Reactor = StatisticsReactor

	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 20
		static let cellHeight: CGFloat = 64
	}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var touchAreaView = UIView()
	private lazy var titleLabel = UILabel()
	private lazy var starImageView = UIImageView()
	private lazy var scoreLabel = UILabel()
	private lazy var arrowImageView = UIImageView()
	private lazy var tableView = UITableView()

	// Empty & Error UI
	private lazy var emptyView = HomeEmptyView()
	
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
	private func bindState(_ reactor: StatisticsReactor) {
		reactor.state
			.map { $0.activityList }
			.distinctUntilChanged() // 중복값 무시
			.bind(to: tableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: HomeTableViewCell.className, for: index) as! HomeTableViewCell
				
				// 데이터 설정
				cell.setData(data: data, last: false)
				cell.backgroundColor = R.Color.gray100

				let backgroundView = UIView()
				backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
				cell.selectedBackgroundView = backgroundView
				
				return cell
			}.disposed(by: disposeBag)
		
		// Empty case 여부 판별
		reactor.state
			.map { $0.activityList }
			.distinctUntilChanged() // 중복값 무시
			.map { $0.isEmpty }
			.subscribe(onNext: { [weak self] isEmpty in
				guard let self = self else { return }
				tableView.isHidden = isEmpty
				emptyView.isHidden = !isEmpty
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension StatisticsSatisfactionListView {
	// 외부에서 입력
	func setData(title: String, score: String) {
		self.titleLabel.text = title
		self.scoreLabel.text = score
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsSatisfactionListView {
	// 초기 셋업할 코드들

	override func setAttribute() {
		super.setAttribute()
		
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
		
		scoreLabel = scoreLabel.then {
			$0.text = "1~2점"
			$0.font = R.Font.body2
			$0.textColor = R.Color.orange500
		}
		
		arrowImageView = arrowImageView.then {
			$0.image = R.Icon.arrowDown32
			$0.contentMode = .scaleAspectFit
		}
		
		tableView = tableView.then {
			$0.register(HomeTableViewCell.self)
			$0.backgroundColor = R.Color.gray100
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.rowHeight = UITableView.automaticDimension
			$0.isScrollEnabled = false
			$0.isHidden = true
		}
		
		emptyView = emptyView.then {
			$0.isHidden = false
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(touchAreaView, tableView, emptyView)
		touchAreaView.addSubviews(titleLabel, starImageView, scoreLabel, arrowImageView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		touchAreaView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.leading.trailing.equalToSuperview().inset(UI.sideMargin)
			$0.height.equalTo(48)
		}
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(UI.sideMargin)
		}
		
		starImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(titleLabel.snp.trailing).offset(11)
		}

		scoreLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(starImageView.snp.trailing).offset(4)
		}

		arrowImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.trailing.equalToSuperview().inset(12)
		}
		
		// Table View
		tableView.snp.makeConstraints {
			$0.top.equalTo(touchAreaView.snp.bottom)
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview()
		}
		
		emptyView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.top.equalTo(touchAreaView.snp.bottom)
			$0.height.equalTo(248)
		}
	}
}
