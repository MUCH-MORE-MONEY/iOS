//
//  CustomPushTextViewController.swift
//  MMM
//
//  Created by yuraMacBookPro on 2023/09/26.
//

import UIKit
import SnapKit
import Then
import ReactorKit

final class CustomPushTextSettingViewController: BottomSheetViewController2, View {
    typealias Reactor = CustomPushTextSettingReactor
    
    // MARK: - Properties
    private var titleStr: String = ""
    private var isDark: Bool = false
    private var height: CGFloat
    
    // MARK: - UI Components
    private lazy var containerView = UIView()
    private lazy var stackView = UIStackView() // label & 확인 버튼
    private lazy var checkButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var textField = UITextField()

    
    init(title: String = "", height: CGFloat, sheetMode: BottomSheetViewController2.Mode = .drag, isDark: Bool = false) {
        self.titleStr = title
        self.height = height
        self.isDark = isDark
        super.init(mode: sheetMode, isDark: isDark)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func bind(reactor: CustomPushTextSettingReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension CustomPushTextSettingViewController {
    private func bindAction(_ reactor: CustomPushTextSettingReactor) {
        textField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe { text in
                print(text)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(_ reactor: CustomPushTextSettingReactor) {
        
    }
}

// MARK: - Actions
extension CustomPushTextSettingViewController {
    
}

//MARK: - Attribute & Hierarchy & Layouts
extension CustomPushTextSettingViewController {
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
        
        textField = textField.then {
            $0.placeholder = "나만의 알림 문구를 적어주세요"
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        containerView.addSubviews(stackView, textField)
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
        
        textField.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
