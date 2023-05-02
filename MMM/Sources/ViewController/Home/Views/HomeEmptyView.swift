//
//  HomeEmptyView.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/02.
//

import UIKit
import Then
import SnapKit

final class HomeEmptyView: UIView {
	// MARK: - Properties

	// MARK: - UI Components
	private lazy var stackView = UIStackView() // imageView, label
	private lazy var ivEmpty = UIImageView()
	private lazy var titleLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension HomeEmptyView {
	
	func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
	}
	
	func setAttribute() {
		
		stackView = stackView.then {
			$0.axis = .vertical
			$0.alignment = .center
			$0.spacing = 16
			$0.distribution = .equalSpacing
		}
		
		ivEmpty = ivEmpty.then {
			$0.image = R.Icon.empty144
			$0.contentMode = .scaleAspectFill
		}
		
		titleLabel = titleLabel.then {
			$0.text = "아직 아무것도 없어요\n시작하면 통장에 돈이 쌓일지도?"
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray500
			$0.textAlignment = .center
		}
	}
	
	func setLayout() {
		addSubviews(stackView)
		stackView.addArrangedSubviews(ivEmpty, titleLabel)
		
		ivEmpty.snp.makeConstraints {
			$0.width.equalTo(144)
		}
		
		stackView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
