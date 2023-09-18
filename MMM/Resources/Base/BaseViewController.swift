//
//  BaseViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/18.
//

import UIKit
import RxSwift
import SnapKit

/*
	BaseViewController
	- setAttribute()
		- 프로퍼티 관련 - label.font, ...
	- setDelegate()
		- 델리게이트 패턴 관련 - tablView.delegate = self, ...
	- setHierarchy()
		- 계층 관련 - addSubView, ...
	- setLayout()
		- 레이아웃 관련 - view.snp.makeConstraints
	- setBind()
		- 바인딩 관련 - button.rx.tap.bind
*/

protocol BaseViewControllerProtocol: AnyObject {
	func setAttribute()
	func setDelegate()
	func setHierarchy()
	func setLayout()
	func setBind()
}

class BaseViewController: UIViewController, BaseViewControllerProtocol {
	var disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup() // 초기 셋업할 코드들
	}
	
	// 초기 셋업할 코드들
	@objc open dynamic func setup() {
		setAttribute()
		setHierarchy()
		setLayout()
		setBind()
	}

	@objc open dynamic func setAttribute() {
		view.backgroundColor = R.Color.gray100
	}
	
	@objc open dynamic func setDelegate() { }
	
	@objc open dynamic func setHierarchy() { }
	
	@objc open dynamic func setLayout() { }
	
	@objc open dynamic func setBind() { }
}
