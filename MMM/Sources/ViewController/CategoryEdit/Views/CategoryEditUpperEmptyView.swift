//
//  CategoryEditUpperEmptyView.swift
//  MMM
//
//  Created by geonhyeong on 11/5/23.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class CategoryEditUpperEmptyView: BaseView, View {
	typealias Reactor = CategoryEditUpperReactor

	// MARK: - Properties
	// MARK: - UI Components
	private lazy var stackView = UIStackView() // imageView, label
	private lazy var ivEmpty = UIImageView()
	private lazy var titleLabel = UILabel()
	private lazy var addButton = UIButton()
	
	func bind(reactor: CategoryEditUpperReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditUpperEmptyView {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditUpperReactor) {
		// 카테고리 유형 추가
		addButton.rx.tap
			.withUnretained(self)
			.map { .didTapAddButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditUpperReactor) { }
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditUpperEmptyView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		stackView = stackView.then {
			$0.axis = .vertical
			$0.alignment = .center
			$0.spacing = 20
			$0.distribution = .equalSpacing
		}
		
		ivEmpty = ivEmpty.then {
			$0.image = R.Icon.empty03
			$0.contentMode = .scaleAspectFill
		}
		
		titleLabel = titleLabel.then {
			let attrString = NSMutableAttributedString(string: "카테고리 유형을 만들면\n유형별로 카테고리를 정리할 수 있어요")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 4
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray400
			$0.textAlignment = .center
			$0.numberOfLines = 2
		}
		
		addButton = addButton.then {
			$0.setTitle("+ 카테고리 유형 추가하기", for: .normal)
			$0.titleLabel?.font = R.Font.body1
			$0.backgroundColor = R.Color.black
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.layer.cornerRadius = 4
			$0.layer.shadowColor = UIColor.black.cgColor
			$0.layer.shadowOpacity = 0.25
			$0.layer.shadowOffset = CGSize(width: 0, height: 2)
			$0.layer.shadowRadius = 8
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(stackView)
		stackView.addArrangedSubviews(ivEmpty, titleLabel, addButton)
	}
	
	override func setLayout() {
		super.setLayout()
				
		ivEmpty.snp.makeConstraints {
			$0.width.equalTo(144)
		}
		
		stackView.snp.makeConstraints {
			$0.verticalEdges.equalToSuperview()
			$0.horizontalEdges.equalToSuperview().inset(65)
		}
		
		addButton.snp.makeConstraints {
			$0.height.equalTo(44)
			$0.horizontalEdges.equalToSuperview()
		}
	}
}
