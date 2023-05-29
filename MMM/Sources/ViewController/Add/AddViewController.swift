//
//  AddViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/14.
//

import UIKit
import Combine
import Then
import SnapKit

final class AddViewController: BaseViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()

	// MARK: - UI Components
	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()
	private lazy var typeLabel = UILabel()
	private lazy var dateLabel = UILabel()
	private lazy var priceLabel = UILabel()
	private lazy var nextButton = UIButton()

	public init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
}
//MARK: - Action
extension AddViewController {
	
}
//MARK: - Style & Layouts
private extension AddViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		//MARK: output
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray900
		title = "경제활동 추가"

		scrollView = scrollView.then {
			$0.showsVerticalScrollIndicator = false
		}
		
		typeLabel = typeLabel.then {
			$0.text = "이 경제활동의 성격은"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		dateLabel = dateLabel.then {
			$0.text = "이 경제활동을 한 날짜는"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		priceLabel = priceLabel.then {
			$0.text = "이 경제활동에 사용된 금액은"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		nextButton = nextButton.then {
			$0.setTitle("다음", for: .normal)
			$0.setTitleColor(R.Color.gray100, for: .normal)
			$0.setTitleColor(R.Color.gray100.withAlphaComponent(0.7), for: .highlighted)
			$0.setBackgroundColor(R.Color.orange500, for: .normal)
			$0.titleLabel?.font = R.Font.title1
			$0.setButtonLayer()
		}
	}
	
	private func setLayout() {
		view.addSubviews(scrollView, nextButton)
		scrollView.addSubview(contentView)
		contentView.addSubviews(typeLabel, dateLabel, priceLabel)
		
		scrollView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
			$0.bottom.equalTo(nextButton.snp.top).offset(-16)
		}
		
		contentView.snp.makeConstraints {
			$0.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		typeLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(40)
			$0.leading.trailing.lessThanOrEqualToSuperview().inset(24)
		}
		
		dateLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(155)
			$0.leading.trailing.lessThanOrEqualToSuperview().inset(24)
		}
		
		priceLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(277)
			$0.leading.trailing.lessThanOrEqualToSuperview().inset(24)
		}
		
		nextButton.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
			$0.height.equalTo(56)
		}
	}
}
