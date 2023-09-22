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

// 상속하지 않으려면 final 꼭 붙이기
final class BottomSheetViewController2: BaseViewController {
	// MARK: - Sub Type
	enum Mode {
		case drag
		case fixed
	}
	
	// MARK: - Properties
	private let mode: Mode
	private lazy var MAX_ALPHA: CGFloat = self.mode == .drag ? 0.75 : 0.75
	private lazy var dimmedColor: UIColor = self.mode == .drag ? R.Color.red500 : R.Color.blue050
	
	// MARK: - UI Components
	var sheetView: UIView!
	var dimmedView: UIView!
	
	
	// MARK: - Initializer
	
	init(mode: Mode) {
		self.mode = mode
		super.init(nibName: nil, bundle: nil)
		
		modalPresentationStyle = .overCurrentContext
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life Cycle Methods
	override func viewWillAppear(_: Bool) {
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
			dimmedView.backgroundColor = dimmedColor
			sheetView.transform = .identity
		} else {
			dismiss(animated: true, completion: nil)
		}
	}
	
	func animatePresentView() {
		UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseInOut]) {
			self.dimmedView.backgroundColor = self.dimmedColor
		}
	}

	func animateDismissView() {
		UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseInOut]) {
			self.dimmedView.alpha = 0
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension BottomSheetViewController2 {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		view.backgroundColor = .clear

		sheetView = UIView().then {
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 16
			$0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 왼쪽, 오른쪽 모서리에만 cornerRadius 적용
			$0.clipsToBounds = true
		}

		dimmedView = UIView().then {
			$0.backgroundColor = .clear
		}
	}

	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(dimmedView, sheetView)
	}

	override func setLayout() {
		super.setLayout()
		
		dimmedView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(-1000)
			make.leading.trailing.bottom.equalToSuperview()
		}
	}

	override func setBind() {
		super.setBind()
		
		guard mode == .drag else { return }
		
		sheetView.rx.panGesture()
			.subscribe(onNext: { [weak self] gesture in
				guard let self = self else { return }
				let translation = gesture.translation(in: self.view)
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

		dimmedView.rx.tapGesture()
			.when(.recognized)
			.subscribe(onNext: { [weak self] _ in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
	}

	final func addContentView(view: UIView) {
		sheetView.addSubview(view)

		sheetView.snp.makeConstraints { make in
			make.leading.trailing.bottom.equalToSuperview()
			make.height.equalTo(view.snp.height).offset(48)
		}

		view.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(24)
		}
	}
}

