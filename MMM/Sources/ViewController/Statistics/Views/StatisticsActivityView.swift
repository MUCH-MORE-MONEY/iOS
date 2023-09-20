//
//  StatisticsActivityView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/22.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsActivityView: BaseView, View {
	typealias Reactor = StatisticsReactor
	
	// MARK: - Constants
	private enum UI {
		static let stackViewMargin: UIEdgeInsets = .init(top: 12, left: 20, bottom: 0, right: 0)
		static let ivSatisfactionMargin: UIEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 0)
		static let tableViewMargin: UIEdgeInsets = .init(top: 8, left: 0, bottom: 0, right: 0)

		static let titleHeight: CGFloat = 44
		static let headerHeight: CGFloat = 170
		static let dummyCellHeight: CGFloat = 16
		static let cellHeight: CGFloat = 48
	}
	
	// MARK: - Properties
	private var timer: DispatchSourceTimer?
	private var counter = 1 // 처음 Delay 때문에 0이 아닌 1로 초기화
	private var cntList = 0 // Rank List 갯수

	// MARK: - UI Components
	private lazy var stackView = UIStackView()
	private lazy var satisfactionView = UIView()	// 만족스러운 활동 영역
	private lazy var satisfactionTableView = UITableView()
	private lazy var satisfactionLabel = UILabel()	// 만족스러운 활동
	private lazy var satisfactionImageView = UIImageView()	// ✨
	private lazy var satisfactionTitleLabel = UILabel()
	private lazy var satisfactionPriceLabel = UILabel()

	private lazy var disappointingView = UIView()			// 아쉬운 활동 영역
	private lazy var disappointingTableView = UITableView()
	private lazy var disappointingLabel = UILabel()			// 아쉬운 활동
	private lazy var disappointingImageView = UIImageView() // 💦
	private lazy var disappointingTitleLabel = UILabel()
	private lazy var disappointingPriceLabel = UILabel()

	init(timer: DispatchSourceTimer?) {
		self.timer = timer
		super.init(frame: .zero)
	}
	
	func bind(reactor: StatisticsReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension StatisticsActivityView {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {
		// 만족스러운 활동 List
		reactor.state
			.map { $0.activitySatisfactionList }
			.bind(to: satisfactionTableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: "StatisticsActivityTableViewCell", for: index) as! StatisticsActivityTableViewCell
				
				cell.isUserInteractionEnabled = false // click disable

				// 데이터 설정
				cell.setData(data: data)
				
				return cell
			}.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.activitySatisfactionList }
			.map { $0.count }
			.subscribe(onNext: {
				self.counter = 1
				self.cntList = $0 - 1
			})
			.disposed(by: disposeBag)
		
		// 아쉬운 활동 List
		reactor.state
			.map { $0.activityDisappointingList }
			.bind(to: disappointingTableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: "StatisticsActivityTableViewCell", for: index) as! StatisticsActivityTableViewCell
				
				cell.isUserInteractionEnabled = false // click disable

				// 데이터 설정
				cell.setData(data: data)
				
				return cell
			}.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.isLoading }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: { [weak self] isLoading in
				guard let self = self else { return }
				
				if !isLoading { // 로딩 끝
					// 자연스러운 UI를 위해 미리 초기화
//					self.satisfactionTableView.scrollToRow(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .middle, animated: false) // 해당 인덱스로 이동.
					self.disappointingTableView.scrollToRow(at: NSIndexPath(item: cntList, section: 0) as IndexPath, at: .middle, animated: false) // 해당 인덱스로 이동.
				}
			}).disposed(by: disposeBag)
	}
}
//MARK: - Action
extension StatisticsActivityView {
	private func moveToIndex() {
		// 보여줄 list의 개수 보다 작을 경우
		guard counter <= cntList && cntList != 1 else {
			counter = 0
			return
		}
		
		// 만족스러운 활동
		let indexSatisfaction = IndexPath.init(item: counter, section: 0)
		self.satisfactionTableView.scrollToRow(at: indexSatisfaction, at: .middle, animated: true) // 해당 인덱스로 이동.
		
		// 아쉬운 활동
		let indexDisappointing = IndexPath.init(item: cntList - counter, section: 0)
		self.disappointingTableView.scrollToRow(at: indexDisappointing, at: .middle, animated: true) // 해당 인덱스로 이동.

		self.counter += 1 // 인덱스 증가

		if counter >= cntList + 1 {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				// 만족스러운 활동
				self.satisfactionTableView.scrollToRow(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .top, animated: false)
				
				// 아쉬운 활동
				self.disappointingTableView.scrollToRow(at: NSIndexPath(item: self.cntList, section: 0) as IndexPath, at: .top, animated: false)
				
				self.counter = 1 // 인덱스 초기화
			}
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsActivityView {
	// 초기 셋업할 코드들
	override func setup() {
		super.setup()
		
		setTimer()
	}
	
	private func setTimer() {
		timer?.setEventHandler(handler: moveToIndex)
	}
	
	override func setAttribute() {
		super.setAttribute()
		
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
		
		satisfactionTableView = satisfactionTableView.then {
			$0.register(StatisticsActivityTableViewCell.self)
			$0.backgroundColor = R.Color.black
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.isScrollEnabled = false
			$0.rowHeight = UI.cellHeight
		}
		
		disappointingTableView = disappointingTableView.then {
			$0.register(StatisticsActivityTableViewCell.self)
			$0.backgroundColor = R.Color.black
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.isScrollEnabled = false
			$0.rowHeight = UI.cellHeight
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
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubviews(satisfactionView, disappointingView)
		satisfactionView.addSubviews(satisfactionLabel, satisfactionImageView, satisfactionTableView, satisfactionTitleLabel, satisfactionPriceLabel)
		disappointingView.addSubviews(disappointingLabel, disappointingImageView, disappointingTableView, disappointingTitleLabel, disappointingPriceLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		stackView.snp.makeConstraints {
			$0.top.bottom.equalToSuperview().inset(UI.stackViewMargin.top)
			$0.leading.trailing.equalToSuperview().inset(UI.stackViewMargin.left)
		}
		
		satisfactionLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		disappointingLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		satisfactionImageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalTo(satisfactionLabel.snp.trailing).offset(UI.ivSatisfactionMargin.left)
		}
		
		disappointingImageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalTo(disappointingLabel.snp.trailing).offset(UI.ivSatisfactionMargin.left)
		}
		
		satisfactionTableView.snp.makeConstraints {
			$0.top.equalTo(satisfactionLabel.snp.bottom).offset(UI.tableViewMargin.top)
			$0.trailing.leading.bottom.equalToSuperview()
		}
		
		disappointingTableView.snp.makeConstraints {
			$0.top.equalTo(disappointingLabel.snp.bottom).offset(UI.tableViewMargin.top)
			$0.trailing.leading.bottom.equalToSuperview()
		}
	}
}
