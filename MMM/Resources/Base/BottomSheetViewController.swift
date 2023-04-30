//
//  BottomSheetViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/30.
//

import UIKit
import Then
import SnapKit

class BottomSheetViewController: UIViewController {
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

	// MARK: - UI
	// contentVC: 보여질 UIViewController
	// bgView: bottomSheet 뒤에 깔릴 어두운 UIView
	// bottomSheetView: contentViewController가 올라갈 UIView 그자체
	private let contentVC: UIViewController
	private lazy var bgView = UIView() // 뒷 배경
	private lazy var dragAreaView = UIView() // indicator
	private lazy var dragIndicatorView = UIView() // indicator
	private lazy var bottomSheetView = UIView()
	
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			self.showSheet()
		}
	}
}

extension BottomSheetViewController {
	
	/// height : 높이,
	/// isDrag : 드래그가 가능한지 (false = 불가능)
	func setSetting(height: CGFloat, isDrag: Bool = true, isExpended: Bool = false) {
		self.defaultHeight = height
		self.isDrag = isDrag
		self.isExpended = isExpended
	}
	
	/// percentHeight : 퍼센트로 높이 설정(0~1, 범위내 값이 아니면 설정 안됨, 1은 하지 말기),
	/// isDrag : 드래그가 가능한지 (false: 불가능)
	func setSetting(percentHeight: CGFloat, isDrag: Bool = true, isExpended: Bool = false) {
		guard 0 < percentHeight && percentHeight <= 1 else { return }
		
		self.defaultHeight = view.frame.height * percentHeight
		self.isDrag = isDrag
		self.isExpended = isExpended
	}
}

//MARK: - Action
private extension BottomSheetViewController {
	
	// Sheet를 보이게 하는 메소드
	func showSheet(atState: BottomSheetViewState = .normal) {
		self.view.layoutIfNeeded()
		
		if atState == .normal {
			topConstraint.update(offset: (safeAreaHeight + bottomPadding) - defaultHeight)
		} else {
			topConstraint.update(offset: bottomSheetPanMinTopConstant)
		}
				
		let showSheet = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn) {
			self.view.layoutIfNeeded()
		}
		
		showSheet.addAnimations {
			self.bgView.alpha = 0.5
		}
		
		showSheet.startAnimation()
	}
	
	// Sheet를 숨기거나 닫히는 메소드
	@objc func hideAndCloseSheet() {
		self.view.layoutIfNeeded()
		
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

//MARK: - Bind & Style & Layouts
private extension BottomSheetViewController {
	
	func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
		setTapGesture()
		setPanGesture()
	}
	
	func setAttribute() {
		self.view.backgroundColor = .clear

		bgView = bgView.then {
			$0.backgroundColor = R.Color.gray900 // backgroundColor
			$0.alpha = 0.0 // 스르륵 나타나는 애니메이션 효과를 위해 초기값 0.0으로 지정
			$0.isUserInteractionEnabled = true
		}
		
		bottomSheetView = bottomSheetView.then {
			$0.backgroundColor = .white
			$0.layer.cornerRadius = 16
			$0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 왼쪽, 오른쪽 모서리에만 cornerRadius 적용
			$0.clipsToBounds = true
		}
		
		dragAreaView = dragAreaView.then {
			$0.backgroundColor = R.Color.white
		}
		
		dragIndicatorView = dragIndicatorView.then {
			$0.backgroundColor = R.Color.gray400
			$0.layer.cornerRadius = 2
		}
		
		addChild(contentVC)
		dragAreaView.addSubview(dragIndicatorView)
		bottomSheetView.addSubviews(dragAreaView, contentVC.view)
		contentVC.didMove(toParent: self) // contentVC 입장에서는 언제 부모VC에 추가되는지 모르기 때문에 contentVC에게 추가 및 제거되는 시점을 알려줌
	}
	
	func setLayout() {
		view.addSubviews(bgView, bottomSheetView)

		bgView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
				
		bottomSheetView.snp.makeConstraints {
			topConstraint = $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(safeAreaHeight + bottomPadding).constraint
			$0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
			$0.bottom.equalToSuperview()
		}
		
		dragAreaView.snp.makeConstraints {
			$0.top.leading.trailing.equalToSuperview()
			$0.height.equalTo(34)
		}
		
		dragIndicatorView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(12)
			$0.centerX.equalToSuperview()
			$0.width.equalTo(40)
			$0.height.equalTo(4)
		}
		
		contentVC.view.snp.makeConstraints {
			$0.top.equalTo(dragAreaView.snp.bottom)
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
