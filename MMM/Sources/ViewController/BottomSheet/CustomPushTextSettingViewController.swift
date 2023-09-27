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
    private var updateHeight: CGFloat = 0
    private var bottomPadding: CGFloat {
        return UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaInsets.bottom ?? 0
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        // UnderLine 호출
        super.viewDidLayoutSubviews()
        textField.setUnderLine(color: R.Color.orange500)
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
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, keyboardWillShow: true)
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
//        moveViewWithKeyboard(notification: notification, keyboardWillShow: false)
    }
    
    private func moveViewWithKeyboard(notification: NSNotification, keyboardWillShow: Bool) {
        // Keyboard's size
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        
        // Keyboard's animation duration
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // Keyboard's animation curve
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        let isSmall = UIScreen.main.bounds.size.height <= 667.0 // 4.7 inch



        if keyboardWillShow {
//            let height = self.containerView.frame.height
            updateHeight = height + self.containerView.frame.height
           

            containerView.snp.updateConstraints {
                $0.height.equalTo(updateHeight + height - 32.0) // 32(Super Class의 Drag 영역)를 반드시 뺴줘야한다.
            }
        } else {
            updateHeight = 0
            
            containerView.snp.updateConstraints {
                $0.height.equalTo(height - 32.0)
            }
        }
        
        // 키보드 애니메이션과 동일한 방식으로 보기 애니메이션 적용하기
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            // Update Constraints
            self?.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
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
//            $0.setUnderLine(color: R.Color.orange500)
            $0.placeholder = "나만의 알림 문구를 적어주세요"
            $0.font = R.Font.h2
            $0.textColor = R.Color.gray900
            $0.setClearButton(with: R.Icon.cancel, mode: .whileEditing)
            $0.becomeFirstResponder()
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
