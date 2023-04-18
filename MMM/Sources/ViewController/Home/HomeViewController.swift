//
//  HomeViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import UIKit
import Combine
import Then
import SnapKit
import FSCalendar

class HomeViewController: UIViewController {
	private lazy var cancellables: Set<AnyCancellable> = .init()
	private let viewModel = HomeViewModel()

	// MARK: - UI Components
	private lazy var monthButtonItem = UIBarButtonItem()
	private lazy var todayButtonItem = UIBarButtonItem()
	private lazy var monthButton = UIButton()
	private lazy var todayButton = UIButton()
	private lazy var settingButton = UIBarButtonItem()
	private lazy var tableView = UITableView()
	
	private lazy var calendar = FSCalendar()
	private lazy var scopeGesture = UIPanGestureRecognizer()
	
	public init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		self.navigationController?.setNavigationBarHidden(true, animated: animated)	// navigation bar 숨김
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated) // navigation bar 노출
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent // status text color 변경
	}
}

//MARK: - Action
extension HomeViewController {

	// 오늘 날짜로 돌아오기
	func didTapTodayButton() {
		self.calendar.select(Date())
	}
}

//MARK: - Style & Layouts
extension HomeViewController {
	private func setup() {
		// 초기 셋업할 코드들
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		todayButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapTodayButton)
			.store(in: &cancellables)
//		checkButton.tapPublisher
//			.receive(on: DispatchQueue.main)
//			.sinkOnMainThread(receiveValue: go)
//			.store(in: &cancellables)
		
		// 예시
//		UITextField().textPublisher
//			.receive(on: DispatchQueue.main)
//			.assign(to: \.passwordInput, on: viewModel)
//			.store(in: &cancellables)
		
		//MARK: output
//		viewModel
//			.transform(input: viewModel.input.eraseToAnyPublisher())
//			.sinkOnMainThread(receiveValue: { [weak self] state in
//				switch state {
//				case .errorMessage(_):
//					break
//				case .toggleButton(isEnabled: let isEnabled):
//					self?.toggleCheckButton(isEnabled)
//				}
//			}).store(in: &cancellables)
		viewModel.isMatchPasswordInput
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: go2)
			.store(in: &cancellables)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		view.addGestureRecognizer(self.scopeGesture)
		navigationItem.leftBarButtonItem = monthButtonItem
		navigationItem.rightBarButtonItems = [settingButton, todayButtonItem]

		monthButton = monthButton.then {
			$0.frame = .init(origin: .zero, size: .init(width: 100, height: 24))
			$0.setTitle(Date().getFormattedDate(format: "M월"), for: .normal)
			$0.setImage(R.Icon.arrowExpandMore16, for: .normal)
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.imageView?.contentMode = .scaleAspectFit
			$0.titleLabel?.font = R.Font.h5
			$0.contentHorizontalAlignment = .left
			$0.semanticContentAttribute = .forceRightToLeft //<- 중요
			$0.imageEdgeInsets = .init(top: 0, left: 11, bottom: 0, right: 0) // 이미지 여백
		}
		
		monthButtonItem = monthButtonItem.then {
			$0.customView = monthButton
		}
		
		todayButton = todayButton.then {
			$0.frame = .init(origin: .zero, size: .init(width: 49, height: 24))
			$0.setTitle("오늘", for: .normal)
			$0.setTitleColor(R.Color.gray300, for: .normal)
			$0.setBackgroundColor(R.Color.gray800, for: .highlighted)
			$0.titleLabel?.font = R.Font.body3
			$0.layer.cornerRadius = 12
			$0.layer.borderWidth = 2
			$0.layer.borderColor = R.Color.gray800.cgColor
		}
		
		todayButtonItem = todayButtonItem.then {
			$0.customView = todayButton
		}
		
		settingButton = settingButton.then {
			$0.image = R.Icon.setting
			$0.style = .plain
		}
		
		calendar = calendar.then {
			$0.backgroundColor = R.Color.gray900
			$0.select(Date())
			$0.scope = .month		// 한달 단위(기본값)로 보여주기
			$0.delegate = self
			$0.dataSource = self
		}
		
		scopeGesture = scopeGesture.then {
			$0.addTarget(self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
			$0.delegate = self
			$0.minimumNumberOfTouches = 1
			$0.maximumNumberOfTouches = 2
		}
		
		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.backgroundColor = R.Color.gray100
			$0.showsVerticalScrollIndicator = false
			$0.register(HomeTableViewCell.self)
			$0.panGestureRecognizer.require(toFail: self.scopeGesture)
			$0.separatorInset.left = 20
			$0.separatorInset.right = 20
		}
		
		view.addSubviews(calendar, tableView)
	}
	
	private func setLayout() {
		calendar.snp.makeConstraints {
			$0.top.left.right.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(300)
		}
		
		tableView.snp.makeConstraints {
			$0.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
			$0.top.equalTo(calendar.snp.bottom)
		}
	}
}

//MARK: - FSCalendar DataSource, Delegate
extension HomeViewController: FSCalendarDataSource, FSCalendarDelegate {
	// 캘린더 선택
	func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//		let selectedDates = calendar.selectedDates.map({dateFormatter.string(from: $0)}) // 선택된 날짜

		if monthPosition == .next || monthPosition == .previous {
			calendar.setCurrentPage(date, animated: true)
		}
	}
	
	// 스크롤시, calendar 높이 조절
	func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
		calendar.snp.updateConstraints {
			$0.height.equalTo(bounds.height) // 높이 변경
		}
		self.view.layoutIfNeeded()
	}
	

	// page가 변경될때 month 변경
	func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
		monthButton.setTitle(calendar.currentPage.getFormattedDate(format: "M월"), for: .normal)
	}
}
}

//MARK: - UIGesture Recognizer Delegate
extension HomeViewController: UIGestureRecognizerDelegate {
	// 스크롤 제스쳐
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
		if shouldBegin {
			let velocity = self.scopeGesture.velocity(in: self.view)
			switch self.calendar.scope {
			case .month:
				return velocity.y < 0
			case .week:
				return velocity.y > 0
			default:
				return false
			}
		}
		return shouldBegin
	}
}

//MARK: - UITableView DataSource
extension HomeViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Calendar.getDummyList().count // 임시
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let padding: CGFloat = 24
		return Calendar.getDummyList()[indexPath.row].memo.isEmpty ? 42 + padding : 64 + padding
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.className, for: indexPath) as! HomeTableViewCell
		
		cell.setUp(data: Calendar.getDummyList()[indexPath.row])
		cell.backgroundColor = R.Color.gray100

		if indexPath.row == Calendar.getDummyList().count - 1 {
			// 마지막 cell은 bottom border 제거
			DispatchQueue.main.async {
				cell.addAboveTheBottomBorderWithColor(color: R.Color.gray100)
			}
		}
		
		return cell
	}
}
//MARK: - UITableView Delegate
extension HomeViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
