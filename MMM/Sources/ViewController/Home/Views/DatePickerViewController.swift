//
//  DatePickerViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/30.
//

import UIKit

class DatePickerViewController: UIViewController {

	// MARK: - UI
	private lazy var stackView = UIStackView() // 날짜 이동, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var datePicker = UIDatePicker()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
}

//MARK: - Style & Layouts
extension DatePickerViewController {
	
	func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
	}
	
	func setAttribute() {
		self.view.backgroundColor = .white
		
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.alignment = .center
			$0.distribution = .equalCentering
		}
		
		titleLabel = titleLabel.then {
			$0.text = "날짜 이동"
			$0.font = R.Font.h5
			$0.textColor = R.Color.black
			$0.textAlignment = .left
		}
		
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(R.Color.black, for: .normal)
			$0.setTitleColor(R.Color.black.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .right
			$0.titleLabel?.font = R.Font.title3
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
		}
		
		datePicker = datePicker.then {
			$0.preferredDatePickerStyle = .wheels
			$0.datePickerMode = .date
		}
	}
	
	func setLayout() {
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
