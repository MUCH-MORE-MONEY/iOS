//
//  SatisfactionBottomSheetViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/20.
//

import UIKit
import SnapKit
import Then
import ReactorKit

enum Satisfaction: Int {
	case low	// 1~2점
	case middle	// 3점
	case hight	// 4~5점
	
	var title: String {
		switch self {
		case .low: return "아쉬운 활동 줄이기"
		case .middle: return "평범한 활동 돌아보기"
		case .hight: return "만족스러운 활동 늘리기"
		}
	}
	
	var score: String {
		switch self {
		case .low: return "1~2점"
		case .middle: return "3점"
		case .hight: return "4~5점"
		}
	}
}

// 상속하지 않으려면 final 꼭 붙이기
final class SatisfactionBottomSheetViewController: BottomSheetViewController2, View {
	typealias Reactor = SatisfactionBottomSheetReactor
	// MARK: - Sub Type
	
	// MARK: - Properties
	private var titleStr: String = ""
	private var satisfaction: Satisfaction
	private var isDark: Bool = false // 다크 모드 지정
	private var height: CGFloat

	// MARK: - UI Components
	private lazy var containerView = UIView()
	private lazy var stackView = UIStackView() // Title Label, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var tableView = UITableView()

	init(title: String, satisfaction: Satisfaction, height: CGFloat, sheetMode: BottomSheetViewController2.Mode = .drag, isDark: Bool = false) {
		self.titleStr = title
		self.satisfaction = satisfaction
		self.height = height
		self.isDark = isDark
		super.init(mode: sheetMode, isDark: isDark)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
		view.endEditing(true)
	}
	
	func bind(reactor: SatisfactionBottomSheetReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension SatisfactionBottomSheetViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: SatisfactionBottomSheetReactor) {
		// 확인 버튼
		checkButton.rx.tap
			.map { .setSatisfaction(self.satisfaction) }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		// TableView cell select
		tableView.rx.itemSelected
			.subscribe(onNext: { [weak self] indexPath in
				guard let self = self else { return }
				let cell = tableView.cellForRow(at: indexPath) as! SatisfactionTableViewCell
				self.satisfaction = cell.getSatisfaction()
			}).disposed(by: disposeBag)

		// 이전에 선택한 만족도 표시
		tableView.rx.willDisplayCell
			.bind(onNext: { data in
				let cell = data.cell as! SatisfactionTableViewCell
				if cell.getSatisfaction() == self.satisfaction {
					self.tableView.selectRow(at: data.indexPath, animated: true, scrollPosition: .middle)
				}
			}).disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: SatisfactionBottomSheetReactor) {
		reactor.state
			.map { $0.satisfactionList }
			.bind(to: tableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: "SatisfactionTableViewCell", for: index) as! SatisfactionTableViewCell
				// Cell data 설정
				cell.setData(satisfaction: data)
				cell.selectionStyle = .none // 테이블뷰 선택 색상 제거
				return cell
			}.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.dismiss }
			.distinctUntilChanged()
			.filter { $0 == true }
			.subscribe(onNext: { [weak self] _ in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension SatisfactionBottomSheetViewController {
}
//MARK: - Attribute & Hierarchy & Layouts
extension SatisfactionBottomSheetViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
						
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.alignment = .center
			$0.distribution = .equalCentering
		}
		
		titleLabel = titleLabel.then {
			$0.text = titleStr
			$0.font = R.Font.h5
			$0.textColor = isDark ? R.Color.gray200 : R.Color.black
			$0.textAlignment = .left
		}
		
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
			$0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .right
			$0.titleLabel?.font = R.Font.title3
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
		
		tableView = tableView.then {
			$0.register(SatisfactionTableViewCell.self)
			$0.backgroundColor = R.Color.white
			$0.showsVerticalScrollIndicator = false // indicator 제거
			$0.separatorStyle = .none
			$0.rowHeight = 52
			$0.bounces = false			// TableView Scroll 방지
			$0.isScrollEnabled = false
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		containerView.addSubviews(stackView, tableView)
		stackView.addArrangedSubviews(titleLabel, checkButton)
		addContentView(view: containerView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		containerView.snp.makeConstraints {
			$0.height.equalTo(height - 32.0) // 32(Super Class의 Drag 영역)를 반드시 뺴줘야한다.
		}
		
		stackView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(28)
		}
		
		tableView.snp.makeConstraints {
			$0.top.equalTo(stackView.snp.bottom)
			$0.leading.trailing.bottom.equalToSuperview()
		}
	}
}
