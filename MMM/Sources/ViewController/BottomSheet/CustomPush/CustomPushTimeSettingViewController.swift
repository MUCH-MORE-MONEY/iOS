//
//  CustomPushTimeSettingViewController.swift
//  MMM
//
//  Created by yuraMacBookPro on 2023/09/27.
//

import UIKit
import SnapKit
import Then
import ReactorKit

final class CustomPushTimeSettingViewController: BottomSheetViewController2, View {
    typealias Reactor = CustomPushTimeSettingReactor
    // MARK: - Properties
    private var titleStr: String = ""
    private var isDark: Bool = false
    private var height: CGFloat
    private var textFieldText: String = ""
    private var date: Date
    
    // MARK: - UI Components
    private lazy var containerView = UIView()
    private lazy var stackView = UIStackView() // label & 확인 버튼
    private lazy var checkButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var datePicker = UIDatePicker()
    
    init(title: String = "", height: CGFloat, date: Date = Date(), sheetMode: BottomSheetViewController2.Mode = .drag, isDark: Bool = false) {
        self.titleStr = title
        self.height = height
        self.isDark = isDark
        self.date = date
        super.init(mode: sheetMode, isDark: isDark)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func bind(reactor: CustomPushTimeSettingReactor) {
        bindAction(reactor)
        bindState(reactor)
    }

}

// MARK: - Bind
extension CustomPushTimeSettingViewController {
    private func bindAction(_ reactor: CustomPushTimeSettingReactor) {
        
    }
    
    private func bindState(_ reactor: CustomPushTimeSettingReactor) {
        
    }
}

// MARK: - Actions
extension CustomPushTimeSettingViewController {
    
}

//MARK: - Attribute & Hierarchy & Layouts
extension CustomPushTimeSettingViewController {
    override func setAttribute() {
        super.setAttribute()
        
        containerView = containerView.then {
            $0.backgroundColor = isDark ? R.Color.gray900 : .white
        }
        
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
        
        datePicker = datePicker.then {
            $0.date = date
            $0.preferredDatePickerStyle = .wheels
            $0.datePickerMode = .time
            $0.setValue(isDark ? R.Color.gray200 : R.Color.black, forKeyPath: "textColor")
            $0.locale = Locale(identifier: "en_US")
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        containerView.addSubviews(stackView, datePicker)
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
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(38.5)
        }
    }
}
