//
//  CategoryEditTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import SnapKit
import Then
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditTableViewCell: BaseTableViewCell, View {
	typealias Reactor = CategoryEditTableViewCellReactor

	// MARK: - Constants
	private enum UI {
		static let contentMargin: UIEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
	}
	
	// MARK: - UI Components
	lazy var titleLabel = UILabel()
	private lazy var editButton = UIButton()
	private lazy var dragButton = UIButton()
	private lazy var separator = UIView()

	// 재활용 셀 중접오류 해결
	override func prepareForReuse() {
		self.separator.isHidden = true
	}
	
	func bind(reactor: CategoryEditTableViewCellReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditTableViewCell {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditTableViewCellReactor) {
		editButton.rx.tap
			.withUnretained(self)
			.map { .didTapEditButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditTableViewCellReactor) {
		reactor.state
			.map { $0.categoryHeader }
			.distinctUntilChanged() // 중복값 무시
			.subscribe(onNext: { [weak self] categoryHeader in
				self?.titleLabel.text = categoryHeader.title
			})
			.disposed(by: disposeBag)
	}
}

//MARK: - Action
extension CategoryEditTableViewCell {
	func setData(last: Bool) {
		DispatchQueue.main.async {
			self.separator.isHidden = last
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditTableViewCell {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.gray900

		titleLabel = titleLabel.then {
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray100
			$0.textAlignment = .left
		}
		
		editButton = editButton.then {
			$0.setImage(R.Icon.iconEditGray24, for: .normal)
			$0.setImage(R.Icon.iconEditGray24?.alpha(0.7), for: .highlighted)
			$0.imageView?.contentMode = .scaleAspectFit
		}
		
		dragButton = dragButton.then {
			$0.setImage(R.Icon.drag, for: .normal)
			$0.setImage(R.Icon.drag?.alpha(0.7), for: .highlighted)
			$0.imageView?.contentMode = .scaleAspectFit
		}
		
		separator = separator.then {
			$0.isHidden = true
			$0.backgroundColor = R.Color.gray800
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		contentView.addSubviews(titleLabel, editButton, dragButton, separator)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(UI.contentMargin.left)
			$0.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-4)
		}
		
		dragButton.snp.makeConstraints {
			$0.centerY.equalTo(titleLabel)
			$0.trailing.equalToSuperview().inset(UI.contentMargin.right)
			$0.width.height.equalTo(24)
		}
		
		editButton.snp.makeConstraints {
			$0.centerY.equalTo(titleLabel)
			$0.trailing.equalTo(dragButton.snp.leading).offset(-6)
			$0.width.height.equalTo(24)
		}
		
		separator.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(UI.contentMargin.right)
			$0.bottom.equalToSuperview()
			$0.height.equalTo(1)
		}
	}
}
