//
//  BottomSheetViewController2.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/19.
//

import UIKit
import Then
import SnapKit
import RxGesture

class BottomSheetViewController2: BaseViewController {
	// MARK: - Sub Type
	// bottomSheet 올라와있는 정도에 따른 상태
	enum Mode {
		case drag
		case fixed
	}
	
	// MARK: - Properties
	private let mode: Mode
	private let isDark: Bool
	private lazy var MAX_ALPHA: CGFloat = 0.5
	private lazy var dimmedColor: UIColor = R.Color.black

	// MARK: - UI Components
	private var sheetView: UIView!
	private var dimmedView: UIView!
	private var dragAreaView: UIView! // indicator
	private var dragIndicatorView: UIView! // indicator

	init(mode: Mode = .drag, isDark: Bool = false) {
		self.mode = mode
		self.isDark = isDark
		super.init(nibName: nil, bundle: nil)
		
		modalPresentationStyle = .overFullScreen
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life Cycle Methods
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		animatePresentView()
	}
	
	override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		self.animateDismissView()
		super.dismiss(animated: flag, completion: completion)
	}
}
//MARK: - Action
extension BottomSheetViewController2 {
	// MARK: - Dismiss Sheet
	func willTransition(to transitionY: CGFloat) {
		guard transitionY > 0 else { return }

		sheetView.transform = CGAffineTransform(translationX: 0, y: transitionY)
	}

	func endTransition(at transitionY: CGFloat) {
		if transitionY < sheetView.bounds.height / 3.0 {
			dimmedView.backgroundColor = dimmedColor.withAlphaComponent(self.MAX_ALPHA)
			sheetView.transform = .identity
		} else {
			dismiss(animated: true, completion: nil)
		}
	}
	
	func animatePresentView() {
		UIView.animate(withDuration: 0.2, delay: 0.35, options: [.curveEaseInOut]) {
			self.dimmedView.backgroundColor = self.dimmedColor.withAlphaComponent(self.MAX_ALPHA)
		}
	}

	func animateDismissView() {
		self.dimmedView.alpha = 0.0
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension BottomSheetViewController2 {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		view.backgroundColor = .clear

		dragAreaView = UIView().then {
			$0.backgroundColor = isDark ? R.Color.gray900 : .white
		}
		
		dragIndicatorView = UIView().then {
			$0.backgroundColor = R.Color.gray400
			$0.layer.cornerRadius = 2
			$0.isHidden = mode != .drag
		}
		
		sheetView = UIView().then {
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 16
			$0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 왼쪽, 오른쪽 모서리에만 cornerRadius 적용
			$0.clipsToBounds = true
			$0.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
		}

		dimmedView = UIView().then {
			$0.backgroundColor = .clear
		}
	}

	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(dimmedView, sheetView)
		sheetView.addSubviews(dragAreaView)
		dragAreaView.addSubview(dragIndicatorView)
	}

	override func setLayout() {
		super.setLayout()
		
		dimmedView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}

	override func setBind() {
		super.setBind()
		
		dimmedView.rx.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [weak self] _ in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
		
		guard mode == .drag else { return }
		
		dragAreaView.rx.panGesture()
			.subscribe(onNext: { [weak self] gesture in
				guard let self = self else { return }
				let translation = gesture.translation(in: self.view) // drag 크기
				guard translation.y > 0 else { return }
				
				let dismissPercent = self.MAX_ALPHA - (translation.y / self.sheetView.bounds.height)

				self.dimmedView.backgroundColor = self.dimmedColor.withAlphaComponent(dismissPercent)

				switch gesture.state {
				case .changed: self.willTransition(to: translation.y)
				case .ended: self.endTransition(at: translation.y)
				default: break
				}
			})
			.disposed(by: disposeBag)
	}

	final func addContentView(view: UIView) {
		sheetView.addSubview(view)
		
		sheetView.snp.makeConstraints {
			$0.leading.trailing.bottom.equalToSuperview()
			$0.height.equalTo(view.snp.height).offset(24)
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

		view.snp.makeConstraints {
			$0.top.lessThanOrEqualTo(dragAreaView.snp.bottom) // lessThan으로 snapkit 오류 해결
			$0.leading.trailing.bottom.equalToSuperview()
		}
	}
}

