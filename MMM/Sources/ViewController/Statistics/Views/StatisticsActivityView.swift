//
//  StatisticsActivityView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/22.
//

import Then
import SnapKit
import ReactorKit

final class StatisticsActivityView: UIView, View {
	typealias Reactor = StatisticsReactor
	
	// MARK: - Properties
	var disposeBag: DisposeBag = DisposeBag()
	private var timer = Timer()
	private var couter = 0

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
					self.disappointingTableView.scrollToRow(at: NSIndexPath(item: 3, section: 0) as IndexPath, at: .middle, animated: false) // 해당 인덱스로 이동.
				}
			}).disposed(by: disposeBag)
	}
}
//MARK: - Action
extension StatisticsActivityView {
	@objc private func moveToIndex() {
		// 만족스러운 활동
		let indexSatisfaction = IndexPath.init(item: couter, section: 0)
		self.satisfactionTableView.scrollToRow(at: indexSatisfaction, at: .middle, animated: true) // 해당 인덱스로 이동.
		
		// 아쉬운 활동
		let indexDisappointing = IndexPath.init(item: 3 - couter, section: 0)
		self.disappointingTableView.scrollToRow(at: indexDisappointing, at: .middle, animated: true) // 해당 인덱스로 이동.

		self.couter += 1 // 인덱스 증가

		if couter >= 4 {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				// 만족스러운 활동
				self.satisfactionTableView.scrollToRow(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .top, animated: false)
				
				// 아쉬운 활동
				self.disappointingTableView.scrollToRow(at: NSIndexPath(item: 3, section: 0) as IndexPath, at: .top, animated: false)
				
				self.couter = 0 // 인덱스 초기화
			}
		}
	}
}
//MARK: - Style & Layouts
private extension StatisticsActivityView {
	// 초기 셋업할 코드들
	private func setup() {
		setTimer()
		setAttribute()
		setLayout()
	}
	
	private func setTimer() {
		timer = Timer.scheduledTimer(
			timeInterval: 1,
			target: self,
			selector: #selector(moveToIndex),
			userInfo: nil,
			repeats: true
		)
	}
	
	private func setAttribute() {
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
			$0.rowHeight = 48
		}
		
		disappointingTableView = disappointingTableView.then {
			$0.register(StatisticsActivityTableViewCell.self)
			$0.backgroundColor = R.Color.black
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.isScrollEnabled = false
			$0.rowHeight = 48
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
	
	private func setLayout() {
		addSubview(stackView)
		stackView.addArrangedSubviews(satisfactionView, disappointingView)
		satisfactionView.addSubviews(satisfactionLabel, satisfactionImageView, satisfactionTableView, satisfactionTitleLabel, satisfactionPriceLabel)
		disappointingView.addSubviews(disappointingLabel, disappointingImageView, disappointingTableView, disappointingTitleLabel, disappointingPriceLabel)
		
		stackView.snp.makeConstraints {
			$0.top.bottom.equalToSuperview().inset(12)
			$0.leading.trailing.equalToSuperview().inset(20)
		}
		
		satisfactionLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		disappointingLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		satisfactionImageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalTo(satisfactionLabel.snp.trailing).offset(2)
		}
		
		disappointingImageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalTo(disappointingLabel.snp.trailing).offset(2)
		}
		
		satisfactionTableView.snp.makeConstraints {
			$0.top.equalTo(satisfactionLabel.snp.bottom).offset(8)
			$0.trailing.leading.bottom.equalToSuperview()
		}
		
		disappointingTableView.snp.makeConstraints {
			$0.top.equalTo(disappointingLabel.snp.bottom).offset(8)
			$0.trailing.leading.bottom.equalToSuperview()
		}
		
		
//		satisfactionTitleLabel.snp.makeConstraints {
//			$0.bottom.equalTo(disappointingPriceLabel.snp.top).offset(-8)
//			$0.leading.equalToSuperview()
//		}
		
//		disappointingTitleLabel.snp.makeConstraints {
//			$0.bottom.equalTo(disappointingPriceLabel.snp.top).offset(-8)
//			$0.leading.equalToSuperview()
//		}
		
//		satisfactionPriceLabel.snp.makeConstraints {
//			$0.leading.bottom.equalToSuperview()
//		}
		
//		disappointingPriceLabel.snp.makeConstraints {
//			$0.leading.bottom.equalToSuperview()
//		}
	}
}
