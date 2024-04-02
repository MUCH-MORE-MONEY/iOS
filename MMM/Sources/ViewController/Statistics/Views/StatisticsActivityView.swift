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
	private var indexSatisfaction = 1 // 처음 Delay 때문에 0이 아닌 1로 초기화
	private var cntSatisfaction = 0 // Rank List 갯수
	private var indexDisappointing = 1 // 처음 Delay 때문에 0이 아닌 1로 초기화
	private var cntDisappointing = 0 // Rank List 갯수
	
	// MARK: - UI Components
	private lazy var stackView = UIStackView()
	private lazy var satisfactionView = UIView()	// 만족스러운 활동 영역
	private lazy var satisfactionTableView = UITableView()
	private lazy var satisfactionLabel = UILabel()	// 만족스러운 활동
	private lazy var satisfactionImageView = UIImageView()	// ✨
	private lazy var satisfactionEmptyTitleLabel = UILabel()
	private lazy var satisfactionEmptyPriceLabel = UILabel()
	
	private lazy var disappointingView = UIView()			// 아쉬운 활동 영역
	private lazy var disappointingTableView = UITableView()
	private lazy var disappointingLabel = UILabel()			// 아쉬운 활동
	private lazy var disappointingImageView = UIImageView() // 💦
	private lazy var disappointingEmptyTitleLabel = UILabel()
	private lazy var disappointingEmptyPriceLabel = UILabel()
	
	// 스켈레톤 UI
	private lazy var satisfactionLabelView = UIView()
	private lazy var satisfactionTitleView = UIView()
	private lazy var satisfactionPriceView = UIView()
	private lazy var satisfactionLabelLayer = CAGradientLayer()
	private lazy var satisfactionTitleLayer = CAGradientLayer()
	private lazy var satisfactionPriceLayer = CAGradientLayer()
	
	private lazy var disappointingLabelView = UIView()
	private lazy var disappointingTitleView = UIView()
	private lazy var disappointingPriceView = UIView()
	private lazy var disappointingLabelLayer = CAGradientLayer()
	private lazy var disappointingTitleLayer = CAGradientLayer()
	private lazy var disappointingPriceLayer = CAGradientLayer()

	init(timer: DispatchSourceTimer?) {
		self.timer = timer
		super.init(frame: .zero)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		satisfactionLabelLayer.frame = satisfactionLabelView.bounds
		satisfactionLabelLayer.cornerRadius = 4
		
		satisfactionTitleLayer.frame = satisfactionTitleView.bounds
		satisfactionTitleLayer.cornerRadius = 4
		
		satisfactionPriceLayer.frame = satisfactionPriceView.bounds
		satisfactionPriceLayer.cornerRadius = 4
		
		disappointingLabelLayer.frame = disappointingLabelView.bounds
		disappointingLabelLayer.cornerRadius = 4
		
		disappointingTitleLayer.frame = disappointingTitleView.bounds
		disappointingTitleLayer.cornerRadius = 4
		
		disappointingPriceLayer.frame = disappointingPriceView.bounds
		disappointingPriceLayer.cornerRadius = 4
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
			.distinctUntilChanged() // 중복값 무시
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
			.distinctUntilChanged() // 중복값 무시
			.bind(to: disappointingTableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: "StatisticsActivityTableViewCell", for: index) as! StatisticsActivityTableViewCell
				
				cell.isUserInteractionEnabled = false // click disable

				// 데이터 설정
				cell.setData(data: data)
				
				return cell
			}.disposed(by: disposeBag)
		
		// 만족스러운 활동
		reactor.state
			.map { $0.activitySatisfactionList }
			.distinctUntilChanged() // 중복값 무시
			.map { $0.count }
			.subscribe(onNext: { [weak self] count in
				guard let self = self else { return }
				
				self.indexSatisfaction = 1
				self.cntSatisfaction = count - 1
				
				if count != 0 {
					satisfactionEmptyTitleLabel.isHidden = true
					satisfactionEmptyPriceLabel.isHidden = true
				} else {
					satisfactionEmptyTitleLabel.isHidden = false
					satisfactionEmptyPriceLabel.isHidden = false
				}
			})
			.disposed(by: disposeBag)
		
		// 아쉬운 활동
		reactor.state
			.map { $0.activityDisappointingList }
			.distinctUntilChanged() // 중복값 무시
			.map { $0.count }
			.subscribe(onNext: { [weak self] count in
				guard let self = self else { return }
				self.indexDisappointing = 1
				self.cntDisappointing = count - 1
				
				if count != 0 {
					disappointingTableView.scrollToRow(at: NSIndexPath(item: cntDisappointing, section: 0) as IndexPath, at: .middle, animated: false) // 해당 인덱스로 이동.
					disappointingEmptyTitleLabel.isHidden = true
					disappointingEmptyPriceLabel.isHidden = true
				} else {
					disappointingEmptyTitleLabel.isHidden = false
					disappointingEmptyPriceLabel.isHidden = false
				}
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension StatisticsActivityView {
	func isLoading(_ isLoading: Bool) {
		satisfactionLabel.isHidden = isLoading
		disappointingLabel.isHidden = isLoading
		satisfactionImageView.isHidden = isLoading
		disappointingImageView.isHidden = isLoading
		
		satisfactionLabelView.isHidden = !isLoading
		satisfactionTitleView.isHidden = !isLoading
		satisfactionPriceView.isHidden = !isLoading
		
		disappointingLabelView.isHidden = !isLoading
		disappointingTitleView.isHidden = !isLoading
		disappointingPriceView.isHidden = !isLoading
	}
	
	private func moveToIndex() {
		guard let reactor = reactor else { return }
		
		// 보여줄 list의 개수 보다 작을 경우
		if indexSatisfaction <= cntSatisfaction && cntSatisfaction > 1 {
			// 만족스러운 활동
			let idxSatisfaction = IndexPath.init(item: indexSatisfaction, section: 0)
			self.satisfactionTableView.scrollToRow(at: idxSatisfaction, at: .middle, animated: true) // 해당 인덱스로 이동.

			self.indexSatisfaction += 1 // 인덱스 증가

			if indexSatisfaction > cntSatisfaction {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					// 만족스러운 활동
					if !reactor.currentState.activitySatisfactionList.isEmpty {
						self.satisfactionTableView.scrollToRow(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .top, animated: false)
					}
					self.indexSatisfaction = 1 // 인덱스 초기화
				}
			}
		} else {
			indexSatisfaction = 0
		}
		
		// 보여줄 list의 개수 보다 작을 경우
		if indexDisappointing <= cntDisappointing && cntDisappointing > 1 {
			// 아쉬운 활동
			let idxDisappointing = IndexPath.init(item: cntDisappointing - indexDisappointing, section: 0)
			self.disappointingTableView.scrollToRow(at: idxDisappointing, at: .middle, animated: true) // 해당 인덱스로 이동.

			self.indexDisappointing += 1 // 인덱스 증가

			if indexDisappointing > cntDisappointing {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					// 아쉬운 활동
					if !reactor.currentState.activityDisappointingList.isEmpty {
						self.disappointingTableView.scrollToRow(at: NSIndexPath(item: self.cntDisappointing, section: 0) as IndexPath, at: .top, animated: false)
					}
					
					self.indexDisappointing = 1 // 인덱스 초기화
				}
			}
		} else {
			indexDisappointing = 0
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsActivityView: SkeletonLoadable {
	// 초기 셋업할 코드들
	override func setup() {
		super.setup()
		
		setTimer()
	}
	
	func setTimer() {
		timer?.setEventHandler(handler: moveToIndex)
	}
	
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.black
		layer.cornerRadius = 10
		layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

		let firstGroup = makeAnimationGroup(startColor: R.Color.gray900, endColor: R.Color.gray700)
		firstGroup.beginTime = 0.0
		let secondGroup = makeAnimationGroup(previousGroup: firstGroup, startColor: R.Color.gray900, endColor: R.Color.gray700)

		satisfactionLabelLayer = satisfactionLabelLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(firstGroup, forKey: "backgroundColor")
		}
		
		satisfactionTitleLayer = satisfactionTitleLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(firstGroup, forKey: "backgroundColor")
		}
		
		satisfactionPriceLayer = satisfactionPriceLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(firstGroup, forKey: "backgroundColor")
		}
		
		disappointingLabelLayer = disappointingLabelLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
		
		disappointingTitleLayer = disappointingTitleLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
		
		disappointingPriceLayer = disappointingPriceLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
		
		satisfactionLabelView = satisfactionLabelView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: 77, height: 20))
			$0.layer.addSublayer(satisfactionLabelLayer)
		}
		
		disappointingLabelView = disappointingLabelView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: 77, height: 20))
			$0.layer.addSublayer(disappointingLabelLayer)
		}
		
		let width = UIScreen.width
		let leftMargin = 40, rightMargin = 195
		let totalWidth = Int(width) - leftMargin - rightMargin
		satisfactionTitleView = satisfactionTitleView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: totalWidth, height: 20))
			$0.layer.addSublayer(satisfactionTitleLayer)
		}
		
		disappointingTitleView = disappointingTitleView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: totalWidth, height: 20))
			$0.layer.addSublayer(disappointingTitleLayer)
		}
		
		satisfactionPriceView = satisfactionPriceView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: totalWidth, height: 20))
			$0.layer.addSublayer(satisfactionPriceLayer)
		}
		
		disappointingPriceView = disappointingPriceView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: totalWidth, height: 20))
			$0.layer.addSublayer(disappointingPriceLayer)
		}
		
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
		
		satisfactionEmptyTitleLabel = satisfactionEmptyTitleLabel.then {
			$0.text = "아직 활동이 없어요"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray600
		}
		
		disappointingEmptyTitleLabel = disappointingEmptyTitleLabel.then {
			$0.text = "아직 활동이 없어요"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray600
		}
		
		satisfactionEmptyPriceLabel = satisfactionEmptyPriceLabel.then {
			$0.text = "활동이 기록되면 보여드려요"
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray800
		}
		
		disappointingEmptyPriceLabel = disappointingEmptyPriceLabel.then {
			$0.text = "활동이 기록되면 보여드려요"
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray800
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(stackView, satisfactionLabelView, disappointingLabelView, satisfactionTitleView, disappointingTitleView, satisfactionPriceView, disappointingPriceView)
		stackView.addArrangedSubviews(satisfactionView, disappointingView)
		satisfactionView.addSubviews(satisfactionLabel, satisfactionImageView, satisfactionTableView, satisfactionEmptyTitleLabel, satisfactionEmptyPriceLabel)
		disappointingView.addSubviews(disappointingLabel, disappointingImageView, disappointingTableView, disappointingEmptyTitleLabel, disappointingEmptyPriceLabel)
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
			$0.top.lessThanOrEqualTo(satisfactionLabel.snp.bottom)
			$0.trailing.leading.equalToSuperview()
			$0.bottom.equalToSuperview()
		}
		
		disappointingTableView.snp.makeConstraints {
			$0.top.lessThanOrEqualTo(disappointingLabel.snp.bottom)
			$0.trailing.leading.equalToSuperview()
			$0.bottom.equalToSuperview()
		}
		
		// Empty Case
		satisfactionEmptyTitleLabel.snp.makeConstraints {
			$0.top.equalTo(satisfactionLabel.snp.bottom).offset(UI.tableViewMargin.top)
			$0.trailing.leading.equalToSuperview()
		}
		
		disappointingEmptyTitleLabel.snp.makeConstraints {
			$0.top.equalTo(disappointingLabel.snp.bottom).offset(UI.tableViewMargin.top)
			$0.trailing.leading.equalToSuperview()
		}
		
		satisfactionEmptyPriceLabel.snp.makeConstraints {
			$0.top.equalTo(satisfactionEmptyTitleLabel.snp.bottom).offset(UI.tableViewMargin.top)
			$0.trailing.leading.bottom.equalToSuperview()
		}
		
		disappointingEmptyPriceLabel.snp.makeConstraints {
			$0.top.equalTo(disappointingEmptyTitleLabel.snp.bottom).offset(UI.tableViewMargin.top)
			$0.trailing.leading.bottom.equalToSuperview()
		}
		
		// 스켈레톤 Layer
		satisfactionLabelView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.leading.equalToSuperview().inset(20)
			$0.width.equalTo(77)
			$0.height.equalTo(20)
		}
		
		disappointingLabelView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.leading.equalToSuperview().inset(170)
			$0.width.equalTo(77)
			$0.height.equalTo(20)
		}
		
		let width = UIScreen.width
		let leftMargin = 40, rightMargin = 195
		let totalWidth = Int(width) - leftMargin - rightMargin

		satisfactionTitleView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(40)
			$0.leading.equalToSuperview().inset(20)
			$0.width.equalTo(totalWidth)
			$0.height.equalTo(24)
		}
		
		disappointingTitleView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(40)
			$0.leading.equalToSuperview().inset(170)
			$0.width.equalTo(totalWidth)
			$0.height.equalTo(24)
		}
		
		satisfactionPriceView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(72)
			$0.leading.equalToSuperview().inset(20)
			$0.width.equalTo(totalWidth)
			$0.height.equalTo(20)
		}
		
		disappointingPriceView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(72)
			$0.leading.equalToSuperview().inset(170)
			$0.width.equalTo(totalWidth)
			$0.height.equalTo(20)
		}
	}
}
