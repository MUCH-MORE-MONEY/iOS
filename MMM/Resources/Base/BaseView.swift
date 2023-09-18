//
//  BaseView.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import UIKit
import RxSwift
import RxCocoa

/*
	BaseViewController
	- setAttribute()
		- 프로퍼티 관련 - label.font, ...
	- setHierarchy()
		- 계층 관련 - addSubView, ...
	- setLayout()
		- 레이아웃 관련 - view.snp.makeConstraints, ...
	- setBind()
		- 바인딩 관련 - button.rx.tap.bind, ...
*/

protocol BaseViewProtocol {
	func setAttribute()
	func setHierarchy()
	func setLayout()
	func setBind()
}

class BaseView: UIView, BaseViewProtocol {
	var disposeBag = DisposeBag()
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup() // 초기 셋업할 코드들
	}
	
	// 초기 셋업할 코드들
	func setup() {
		setAttribute()
		setHierarchy()
		setLayout()
		setBind()
	}
	
	@objc open dynamic func setAttribute() { }
	
	@objc open dynamic func setHierarchy() { }
		
	@objc open dynamic func setLayout() { }
	
	@objc open dynamic func setBind() { }
}
