//
//  ToastView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/06/21.
//

import UIKit
import Combine
import Then
import SnapKit

final class ToastView: UIView {
	// MARK: - UI Components
	private lazy var textLabel = UILabel()
	private lazy var retryButton = UIButton()
	private lazy var stackView = UIStackView()
	// MARK: - Properties
	private var cancellable = Set<AnyCancellable>()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension ToastView {
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		retryButton.tapPublisher
			.sinkOnMainThread { _ in
				print("retry")
			}.store(in: &cancellable)
	}
	
	private func setAttribute() {
		addSubviews(stackView)
		stackView.addArrangedSubviews(textLabel, retryButton)
		
		stackView = stackView.then {
			$0.backgroundColor = R.Color.gray900
			$0.axis = .horizontal
			$0.spacing = 16
			$0.alignment = .center
		}
		
		textLabel = textLabel.then {
			$0.text = "일시적인 오류가 발생했습니다."
			$0.numberOfLines = 2
			$0.textColor = R.Color.white
			$0.font = R.Font.title3
		}
		
		retryButton = retryButton.then {
			$0.setTitle("재시도", for: .normal)
			$0.setTitleColor(R.Color.orange500, for: .normal)
		}
	}
	
	private func setLayout() {
		stackView.snp.makeConstraints {
			$0.top.bottom.left.right.equalToSuperview()
		}
	}
}
