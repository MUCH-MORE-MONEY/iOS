//
//  BaseTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/19.
//

import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell, BaseViewProtocol {
	var disposeBag = DisposeBag()
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup() // 초기 셋업할 코드들
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		disposeBag = DisposeBag()
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
