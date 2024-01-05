//
//  BottomSheetViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/30.
//

import UIKit
import Then
import SnapKit

protocol BottomSheetChild: AnyObject {
	func willDismiss()
}

class BottomSheetViewController: UIViewController, BottomSheetChild {
	// bottomSheet 올라와있는 정도에 따른 상태
	enum BottomSheetViewState {
		case expanded
		case normal
	}
	
	// MARK: - Properties
	// defaultHeight: bottomSheet의 기본 높이
	// topConstraint: bottomSheet의 상단 constraint를 조정하기 위한 변수
	private var defaultHeight: CGFloat = 300 // BottomSheet 기본 높이 지정을 위한 프로퍼티
	private var topConstraint: Constraint!
	// Bottom Sheet과 safe Area Top 사이의 최소값을 지정하기 위한 프로퍼티, 기본값 30
	private var bottomSheetPanMinTopConstant: CGFloat = 30.0
	// 드래그 하기 전에 Bottom Sheet의 top Constraint value를 저장하기 위한 프로퍼티
	private lazy var bottomSheetPanStartingTopConstant: CGFloat = bottomSheetPanMinTopConstant
	private var safeAreaHeight: CGFloat {
		return UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaLayoutGuide.layoutFrame.size.height ?? 0
	}
	private var bottomPadding: CGFloat {
		return UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaInsets.bottom ?? 0
	}
	private var isDrag: Bool = true
	private var isExpended: Bool = false
	private var isShadow: Bool = false
	private var isDark: Bool = false

	// MARK: - UI Components
	// contentVC: 보여질 UIViewController
	// bgView: bottomSheet 뒤에 깔릴 어두운 UIView
	// bottomSheetView: contentViewController가 올라갈 UIView 그자체
	private let contentVC: UIViewController!
	private lazy var bgView = UIView() // 뒷 배경
	private lazy var dragAreaView = UIView() // indicator
	private lazy var dragIndicatorView = UIView() // indicator
	private lazy var bottomSheetOuterView = UIView()
	private lazy var bottomSheetInnerView = UIView()
	
	// 이니셜라이저 구현
	init(contentViewController: UIViewController) {
		self.contentVC = contentViewController
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.showSheet()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
}

extension BottomSheetViewController {
	/// height : 높이,
	/// isDrag : 드래그가 가능한지 (false: 불가능, default: true)
	/// isExpended : 확장 가능한지 (false: 불가능, default: false)
	/// isShadow : 그림자가 보이게 할것인지 (true: 보임, default: false)
	func setSetting(height: CGFloat, isDrag: Bool = true, isExpended: Bool = false, isShadow: Bool = false, isDark: Bool = false) {
		self.defaultHeight = height
		self.isDrag = isDrag
		self.isExpended = isExpended
		self.isShadow = isShadow
		self.isDark = isDark
		
		self.dragIndicatorView.isHidden = !isDrag
	}
	
	/// percentHeight : 퍼센트로 높이 설정(0~1, 범위내 값이 아니면 설정 안됨, 1은 하지 말기),
	/// isDrag : 드래그가 가능한지 (false: 불가능, default: true)
	/// isExpended : 확장 가능한지 (false: 불가능, default: false)
	/// isShadow : 그림자가 보이게 할것인지 (true: 보임, default: false)
	/// isDark : 다크모드일떄, 색상인지 (true: white, default: false)
	func setSetting(percentHeight: CGFloat, isDrag: Bool = true, isExpended: Bool = false, isShadow: Bool = false, isDark: Bool = false) {
		guard 0 < percentHeight && percentHeight <= 1 else { return }
		
		self.defaultHeight = view.frame.height * percentHeight
		self.isDrag = isDrag
		self.isExpended = isExpended
		self.isShadow = isShadow
		self.isDark = isDark
		
		self.dragIndicatorView.isHidden = !isDrag
	}
	
	func willDismiss() {
		topConstraint.update(offset: safeAreaHeight + bottomPadding)
		
		let showSheet = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn) {
			self.view.layoutIfNeeded()
		}
		
		showSheet.addAnimations {
			self.bgView.alpha = 0.0
		}
		
		showSheet.addCompletion { (position) in
			if position == .end {
				self.dismiss(animated: true, completion: nil)
			}
		}
		
		showSheet.startAnimation()
	}
}

//MARK: - Action
private extension BottomSheetViewController {
	
	// Sheet를 보이게 하는 메소드
	func showSheet(atState: BottomSheetViewState = .normal) {
		if atState == .normal {
			topConstraint.update(offset: (safeAreaHeight + bottomPadding) - defaultHeight)
		} else {
			topConstraint.update(offset: bottomSheetPanMinTopConstant)
		}
		
		// keyboard 열리는 속도가 0.25인데 그것보다 빠르게(0.5) 나와야함
		let showSheet = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) {
			self.view.layoutIfNeeded()
		}
		
		showSheet.addAnimations {
			if !self.isShadow {
				self.bgView.alpha = 0.5
			} else {
				self.bgView.alpha = 0.05 // 색상을 줘야 gesture 작동
			}
		}
		
		showSheet.startAnimation()
	}
	
	// Sheet를 숨기거나 닫히는 메소드
	@objc func hideAndCloseSheet() {
		view.endEditing(true) // keyboard 닫힘
		willDismiss()
	}
	
	@objc func didTapPanned(_ gesture: UIPanGestureRecognizer) {
		guard let top = topConstraint.layoutConstraints.first?.constant else { return }
		let translation = gesture.translation(in: self.view) // drag 크기
		let velocity = gesture.velocity(in: self.view)

		switch gesture.state {
		case .began: // 드래그 시작
			bottomSheetPanStartingTopConstant = top
		case .changed:
			if isDrag == false { return }
			
			if bottomSheetPanStartingTopConstant + translation.y > bottomSheetPanMinTopConstant {
				topConstraint.update(offset: bottomSheetPanStartingTopConstant + translation.y)
			}
		case .ended:
			if velocity.y > 1500.0 {
				hideAndCloseSheet()
				return
			}
			let defaultPadding = safeAreaHeight + bottomPadding - defaultHeight
			let nearestValue = nearest(to: top, inValues: [bottomSheetPanMinTopConstant, defaultPadding, safeAreaHeight + bottomPadding])
			
			if nearestValue == bottomSheetPanMinTopConstant {
				// .expanded 상태의 BottomSheet
				// 확장 가능한지 확인
				showSheet(atState: isExpended ? .expanded : .normal)
			} else if nearestValue == defaultPadding {
				// .normal 상태의 BottomSheet
				showSheet(atState: .normal)
			} else {
				// Bottom Sheet을 숨기고 현재 View Controller를 dismiss시키기
				hideAndCloseSheet()
			}
		default:
			break
		}
	}
	
	//주어진 CGFloat 배열의 값 중 number로 주어진 값과 가까운 값을 찾아내는 메소드
	func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
		guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) })
		else { return number }
		return nearestVal
	}
}
//MARK: - Bind & Attribute & Hierarchy & Layouts
private extension BottomSheetViewController {
	
	func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
		setTapGesture()
		setPanGesture()
	}
	
	@objc func keyboardWillShow(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification, keyboardWillShow: true)
	}
	
	@objc func keyboardWillHide(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification, keyboardWillShow: false)
	}
	
	func moveViewWithKeyboard(notification: NSNotification, keyboardWillShow: Bool) {
		// Keyboard's size
		guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
		let keyboardHeight = keyboardSize.height
		
		// Keyboard's animation duration
		let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
		
		// Keyboard's animation curve
		let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!

		if keyboardWillShow {
			topConstraint.update(offset: (safeAreaHeight + bottomPadding) - defaultHeight - keyboardHeight)
		} else {
			topConstraint.update(offset: (safeAreaHeight + bottomPadding) - defaultHeight)
		}
		
		// 키보드 애니메이션과 동일한 방식으로 보기 애니메이션 적용하기
		let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
			// Update Constraints
			self?.view.layoutIfNeeded()
		}
		
		animator.startAnimation()
	}
	
	func setAttribute() {
		self.view.backgroundColor = .clear
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		bgView = bgView.then {
			$0.backgroundColor = R.Color.black // backgroundColor
			$0.alpha = 0.0 // 스르륵 나타나는 애니메이션 효과를 위해 초기값 0.0으로 지정
			$0.isUserInteractionEnabled = true
		}
		
		bottomSheetOuterView = bottomSheetOuterView.then {
			if isShadow {
				$0.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
			}
		}
		
		bottomSheetInnerView = bottomSheetInnerView.then {
			$0.backgroundColor = isDark ? R.Color.gray900 : .white
			$0.layer.cornerRadius = 16
			$0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 왼쪽, 오른쪽 모서리에만 cornerRadius 적용
			$0.clipsToBounds = true
		}
		
		dragAreaView = dragAreaView.then {
			$0.backgroundColor = isDark ? R.Color.gray900 : .white
		}
		
		dragIndicatorView = dragIndicatorView.then {
			$0.backgroundColor = R.Color.gray400
			$0.layer.cornerRadius = 2
		}
	}
	
	func setLayout() {
		addChild(contentVC)
		dragAreaView.addSubview(dragIndicatorView)
		bottomSheetOuterView.addSubviews(bottomSheetInnerView)
		bottomSheetInnerView.addSubviews(dragAreaView, contentVC.view)
		contentVC.didMove(toParent: self) // contentVC 입장에서는 언제 부모VC에 추가되는지 모르기 때문에 contentVC에게 추가 및 제거되는 시점을 알려줌
		view.addSubviews(bgView, bottomSheetOuterView)

		bgView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
				
		bottomSheetOuterView.snp.makeConstraints {
			topConstraint = $0.top.equalTo(view.safeAreaLayoutGuide).offset(safeAreaHeight + bottomPadding).constraint
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview()
		}

		bottomSheetInnerView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}

		dragAreaView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(32)
		}

		dragIndicatorView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.centerX.equalToSuperview()
			$0.width.equalTo(40)
			$0.height.equalTo(4)
		}

		contentVC.view.snp.makeConstraints {
			$0.top.lessThanOrEqualTo(dragAreaView.snp.bottom) // lessThan으로 snapkit 오류 해결
			$0.leading.trailing.bottom.equalToSuperview()
		}
	}
	
	/// bgView에 tapGesture 추가하는 함수
	func setTapGesture() {
		let bgViewTap = UITapGestureRecognizer(target: self, action: #selector(hideAndCloseSheet))
		bgView.addGestureRecognizer(bgViewTap)
		bgView.isUserInteractionEnabled = true
	}
	
	/// ViewController의 view에 Pan Gesture Recognizer 추가하는 함수
	func setPanGesture() {
		let viewPan = UIPanGestureRecognizer(target: self, action: #selector(didTapPanned))
		
		// 기본적으로 iOS는 터치가 드래그하였을 때 딜레이가 발생함
		// 우리는 드래그 제스쳐가 바로 발생하길 원하기 때문에 딜레이가 없도록 아래와 같이 설정
		viewPan.delaysTouchesBegan = false
		viewPan.delaysTouchesEnded = false
		dragAreaView.addGestureRecognizer(viewPan)
	}
}
