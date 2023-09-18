//
//  StatisticsHeaderView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import Then
import SnapKit

final class StatisticsHeaderView: UIView {
	// MARK: - UI Components
	private lazy var rangeLabel = UILabel() // 통계 범위
	private lazy var titleLabel = UILabel()
	private lazy var imageView = UIImageView() // Boost 아이콘

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Action
extension StatisticsHeaderView {
	// 외부에서 설정
	func setData(startDate: String, endDate: String) {
		rangeLabel.text = startDate + " ~ " + endDate
	}
	
	// Text 부분적으로 Bold 처리
	private func setSubTextBold() -> NSMutableAttributedString {
		let attributedText1 = NSMutableAttributedString(string: "부스트와 함께\n")
		let attributedText2 = NSMutableAttributedString(string: "만족하는 경제습관 ")
		let attributedText3 = NSMutableAttributedString(string: "만들기!")
		
		// 일반 Text 속성
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 4
		let textAttributes1: [NSAttributedString.Key : Any] = [
			.font: R.Font.body1,
			.foregroundColor: R.Color.white,
			.paragraphStyle: paragraphStyle
		]
		
		// Bold Text 속성
		let textAttributes2: [NSAttributedString.Key : Any] = [
			.font: R.Font.title3,
			.foregroundColor: R.Color.white
		]
		
		attributedText1.addAttributes(textAttributes1, range: NSMakeRange(0, attributedText1.length))
		attributedText2.addAttributes(textAttributes2, range: NSMakeRange(0, attributedText2.length))
		attributedText3.addAttributes(textAttributes1, range: NSMakeRange(0, attributedText3.length))
		
		attributedText1.append(attributedText2)
		attributedText1.append(attributedText3)
		return attributedText1
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension StatisticsHeaderView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		rangeLabel = rangeLabel.then {
			let month = Date().getFormattedDate(format: "MM") // 이번달
			let today = Date().getFormattedDate(format: "dd") // 오늘날짜
			$0.text = "\(month).01 ~ \(month).\(today)"
			$0.font = R.Font.prtendard(family: .medium, size: 12)
			$0.textColor = R.Color.gray500
		}
		
		titleLabel = titleLabel.then {
			$0.attributedText = setSubTextBold()
			$0.numberOfLines = 2
		}
		
		imageView = imageView.then {
			$0.image = R.Icon.characterHappy
			$0.contentMode = .scaleAspectFit
		}
	}
	
	private func setLayout() {
		addSubviews(rangeLabel, titleLabel, imageView)

		rangeLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		titleLabel.snp.makeConstraints {
			$0.top.equalTo(rangeLabel.snp.bottom).offset(6)
			$0.leading.equalToSuperview()
		}
		
		imageView.snp.makeConstraints {
			$0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
			$0.top.trailing.bottom.equalToSuperview()
		}
	}
}
