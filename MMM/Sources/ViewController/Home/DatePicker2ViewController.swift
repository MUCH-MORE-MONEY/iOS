//
//  DatePicker2ViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/22.
//

import UIKit
import Combine
import Then
import SnapKit
import ReactorKit

final class DatePicker2ViewController: UIViewController, View {
	// MARK: - Properties
	private var isDark: Bool = false
	private var date: Date
	weak var delegate: BottomSheetChild?
	var disposeBag: DisposeBag = DisposeBag()
	private let yearList: [Int] = Array(2013...2099)
	private let monthList: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	private let monthDic: [String:Int] = ["January":1, "February":2, "March":3, "April":4, "May":5, "June":6, "July":7, "August":8, "September":9, "October":10, "November":11, "December":12]
	private var selectedYearIndex: Int = 0 // Custom Picker View에서 선택한 년
	private var selectedMonthIndex: Int = 0	// Custom Picker View에서 선택한 달
	private var curMode: Mode
	
	enum Mode {
		case date
		case onlyMonthly
	}

	// MARK: - UI Components
	private lazy var stackView = UIStackView() // 날짜 이동 Label, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var datePicker = UIDatePicker()
	private lazy var monthPicker = UIPickerView()
	
	init(date: Date = Date(), mode: Mode = .date) {
		self.date = date
		self.curMode = mode
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup() // 초기 셋업할 코드들
	}
	
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	func bind(reactor: BottomSheetReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension DatePicker2ViewController {
	// 외부에서 설정
    func setData(title: String, isDark: Bool = false, type:  UIDatePicker.Mode = .date) {
		DispatchQueue.main.async {
			self.titleLabel.text = title
            self.datePicker.datePickerMode = type
		}
		self.isDark = isDark
	}
}
//MARK: - Bind
extension DatePicker2ViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: BottomSheetReactor) {
		// 확인 버튼
		checkButton.rx.tap
			.map { .didTapDateCheckButton(date: (self.curMode == .date ? self.datePicker.date : self.createDateFromYearAndMonth(year: self.yearList[self.selectedYearIndex], month: self.monthList[self.selectedMonthIndex])) ?? Date()) }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: BottomSheetReactor) {
		reactor.state
			.map { $0.successByMonthly }
			.subscribe { [weak self] date in
				guard let self = self else { return }
				self.delegate?.willDismiss()
			}
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
private extension DatePicker2ViewController {
	private func createDateFromYearAndMonth(year: Int, month: String) -> Date? {
		// 현재 달력과 타임존 설정을 사용하여 Calendar 인스턴스 생성
		let calendar = Calendar.current
		
		// DateComponents를 사용하여 year와 month를 설정
		var dateComponents = DateComponents()
		dateComponents.year = year
		dateComponents.month = monthDic[month]
		
		// DateComponents를 사용하여 Date 객체 생성
		if let date = calendar.date(from: dateComponents) {
			return date
		} else {
			return nil // 유효하지 않은 날짜일 경우 nil 반환
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension DatePicker2ViewController {
	private func setAttribute() {
		self.view.backgroundColor = isDark ? R.Color.gray900 : .white
		
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.alignment = .center
			$0.distribution = .equalCentering
		}
		
		titleLabel = titleLabel.then {
			$0.text = "날짜 이동"
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
		
		switch curMode {
		case .date:
			datePicker = datePicker.then {
				$0.date = date
				$0.preferredDatePickerStyle = .wheels
				$0.datePickerMode = .date
				$0.setValue(isDark ? R.Color.gray200 : R.Color.black, forKeyPath: "textColor")
			}
		case .onlyMonthly:
			monthPicker = monthPicker.then {
				$0.delegate = self
				$0.dataSource = self
				
				// 각 component에서 보여줄 초기값.
				let calendar = Calendar.current
				let components = calendar.dateComponents([.year, .month, .day], from: date)
				let initYear = components.year ?? 2023, initMonth = (components.month ?? 1) - 1
				
				guard let initYearIndex = yearList.firstIndex(of: initYear) else { return }

				$0.selectRow(initYearIndex, inComponent: 1, animated: true)
				$0.selectRow(initMonth, inComponent: 0, animated: true)

				// 년, 월이 현재로 선택되어있는 상태에서 확인 버튼을 누를 경우를 위해 추가
				selectedYearIndex = initYearIndex
				selectedMonthIndex = initMonth
			}
		}
	}
	
	private func setLayout() {
		stackView.addArrangedSubviews(titleLabel, checkButton)
		view.addSubviews(stackView)
		
		stackView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(28)
		}
		
		switch curMode {
		case .date:
			view.addSubviews(datePicker)
			
			datePicker.snp.makeConstraints {
				$0.top.equalTo(stackView.snp.bottom).offset(16)
				$0.leading.trailing.equalToSuperview().inset(38.5)
			}
		case .onlyMonthly:
			view.addSubviews(monthPicker)
			
			monthPicker.snp.makeConstraints {
				$0.top.equalTo(stackView.snp.bottom).offset(16)
				$0.leading.trailing.equalToSuperview().inset(38.5)
			}
		}
	}
}
// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension DatePicker2ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	// PickerView의 component를 몇 개인지 정하는 메소드
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	
	// PickerView의 각 component에서 몇 개의 row를 정하는 메소드
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch component {
		case 0:		return monthList.count
		default:	return yearList.count
		}
	}
	
	// PickerView의 각 component에서 각 row에 내용을 정하는 메소드
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch component {
		case 0:		return "\(monthList[row])"
		default:	return "\(yearList[row])"
		}
	}
	
	// 사용자가 선택한 row 값을 저장.
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch component {
		case 0:		selectedMonthIndex = row	// 월 저장
		default:	selectedYearIndex = row		// 년도 저장
		}
	}
}
