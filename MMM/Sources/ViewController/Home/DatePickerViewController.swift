//
//  DatePickerViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/30.
//

import UIKit
import Combine
import Then
import SnapKit

final class DatePickerViewController: UIViewController {
	// MARK: - Properties
	private lazy var cancellables: Set<AnyCancellable> = .init()
	private var isDark: Bool = false
	private var date: Date
	private var viewModel: AnyObject
	weak var delegate: BottomSheetChild?

	// MARK: - UI Components
	private lazy var stackView = UIStackView() // 날짜 이동 Label, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var datePicker = UIDatePicker()
	
	init(viewModel: AnyObject, date: Date = Date()) {
		self.date = date
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if viewModel is AddViewModel {
			let vm = viewModel as! AddViewModel
			vm.date = vm.date ?? Date()
		}
	}
}
//MARK: - Action
extension DatePickerViewController {
	// 외부에서 설정
	func setData(title: String, isDark: Bool = false) {
		DispatchQueue.main.async {
			self.titleLabel.text = title
		}
		self.isDark = isDark
	}
	// MARK: - Private
	// 닫힐때
	private func willDismiss() {
		switch viewModel {
		case is HomeViewModel:
			let viewModel = viewModel as! HomeViewModel
			viewModel.date = datePicker.date
		case is EditActivityViewModel:
			let viewModel = viewModel as! EditActivityViewModel
			viewModel.date = datePicker.date
		case is AddViewModel:
			let viewModel = viewModel as! AddViewModel
			viewModel.date = datePicker.date
		default:
			break
		}
		delegate?.willDismiss()
	}
}
//MARK: - Style & Layouts
private extension DatePickerViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		checkButton.tapPublisher
			.sinkOnMainThread(receiveValue: willDismiss)
			.store(in: &cancellables)
	}
	
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
		
		datePicker = datePicker.then {
			$0.date = date
			$0.preferredDatePickerStyle = .wheels
			$0.datePickerMode = .date
			$0.setValue(isDark ? R.Color.gray200 : R.Color.black, forKeyPath: "textColor")
		}
	}
	
	private func setLayout() {
		stackView.addArrangedSubviews(titleLabel, checkButton)
		view.addSubviews(stackView, datePicker)
		
		stackView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(28)
		}
		
		datePicker.snp.makeConstraints {
			$0.top.equalTo(stackView.snp.bottom).offset(16)
			$0.leading.trailing.equalToSuperview().inset(38.5)
		}
	}
}
