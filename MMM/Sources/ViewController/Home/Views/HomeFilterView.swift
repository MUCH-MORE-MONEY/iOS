//
//  HomeFilterView.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/18.
//

import UIKit
import Combine
import Then
import SnapKit

final class HomeFilterView: UIView {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private var viewModel: HomeViewModel?
	private var isEarn: Bool = true

	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var standardView = UIView()
	private lazy var standardLabel = UILabel()
	private lazy var expandImageView = UIImageView()
	private lazy var middleLabel = UILabel()
	private lazy var colorButton = UIButton()
	private lazy var lastLabel = UILabel()
	private lazy var separator1 = UIView()
	private lazy var separator2 = UIView()

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
extension HomeFilterView {
	// 외부에서 설정
	func setData(viewModel: HomeViewModel, isEarn: Bool) {
		self.viewModel = viewModel
		self.isEarn = isEarn
		titleLabel.text = isEarn ? "수입" : "지출"
		DispatchQueue.main.async {
			self.colorButton.backgroundColor = viewModel.isHighlight ? isEarn ? R.Color.blue400 : R.Color.orange400 : R.Color.gray400
		}
	}
	
	// 외부에서 설정
	func setData(price: Int) {
		self.standardLabel.text = (price / 10_000).withCommas() + "만원 이상"
	}
	
	// 외부에서 설정
	func toggleEnabled(_ isOn: Bool) {
		backgroundColor = isOn ? R.Color.gray900 : R.Color.gray200
		standardLabel.textColor = isOn ? R.Color.white : R.Color.gray400
		colorButton.backgroundColor = isOn ? isEarn ? R.Color.blue400 : R.Color.orange400 : R.Color.gray400
		colorButton.isEnabled = isOn
	}
	
	//MARK: - Private
	// Set Standard 하이라이트
	@objc private func handleTap(sender: UITapGestureRecognizer) {
		// viewModel.isHighlight가 Toggle이 유무
		guard let viewModel = self.viewModel, viewModel.isHighlight else { return }
		
		// 수입/지출에 따른 viewModel (수입:true, 지출:false)
		viewModel.didTapHighlightButton = self.isEarn
	}
}
//MARK: - Style & Layouts
private extension HomeFilterView {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		// 임시: 다음 버전에서 적용
//		colorButton.tapPublisher
//			.sinkOnMainThread(receiveValue: {
//				guard let viewModel = self.viewModel else { return }
//				// 수입/지출에 따른 viewModel (수입:true, 지출:false)
//				viewModel.didTapColorButton = self.isEarn
//			}).store(in: &cancellable)
	}
	
	private func setAttribute() {
		// [view]
		backgroundColor = R.Color.gray900
		layer.cornerRadius = 4

		titleLabel = titleLabel.then {
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray300
		}
		
		standardView = standardView.then {
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
			$0.addGestureRecognizer(tapGesture)
		}
		
		standardLabel = standardLabel.then {
			$0.text = "1만원 이상"
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
		}
		
		expandImageView = expandImageView.then {
			$0.image = R.Icon.arrowExpandMore16
			$0.contentMode = .scaleAspectFill
		}
		
		middleLabel = middleLabel.then {
			$0.text = "일 때,"
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray300
		}
		
		colorButton = colorButton.then {
			$0.layer.cornerRadius = 8
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
		
		lastLabel = lastLabel.then {
			$0.text = "색으로 표시"
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray300
		}
		
		separator1 = separator1.then {
			$0.backgroundColor = R.Color.gray300
		}
		
		separator2 = separator2.then {
			$0.backgroundColor = R.Color.gray300
		}
	}
	
	private func setLayout() {
		addSubviews(titleLabel, standardView, separator1, separator2, middleLabel, colorButton, lastLabel)
		standardView.addSubviews(standardLabel, expandImageView)
		
		titleLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview().inset(12)
		}
		
		standardView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(8)

			$0.leading.equalToSuperview().inset(12)
			$0.trailing.equalTo(expandImageView)
		}
		
		standardLabel.snp.makeConstraints {
			$0.top.leading.bottom.equalToSuperview()
		}
		
		expandImageView.snp.makeConstraints {
			$0.top.bottom.equalTo(standardView)
			$0.leading.greaterThanOrEqualTo(standardLabel.snp.trailing).offset(8)
		}
		
		middleLabel.snp.makeConstraints {
			$0.top.bottom.equalTo(standardView)
			$0.leading.equalTo(expandImageView.snp.trailing).offset(4)
		}
		
		colorButton.snp.makeConstraints {
			$0.top.bottom.equalTo(standardView)
			$0.leading.equalTo(middleLabel.snp.trailing).offset(8)
			$0.width.height.equalTo(16)
			$0.trailing.equalTo(lastLabel.snp.leading).offset(-8)
		}
		
		lastLabel.snp.makeConstraints {
			$0.top.bottom.equalTo(standardView)
			$0.trailing.equalToSuperview().inset(35)
		}
		
		separator1.snp.makeConstraints {
			$0.top.equalTo(standardView.snp.bottom).offset(8)
			$0.bottom.equalToSuperview().inset(14)
			$0.leading.equalToSuperview().inset(12)
			$0.trailing.equalTo(expandImageView)
			$0.height.equalTo(2)
		}
		
		separator2.snp.makeConstraints {
			$0.top.equalTo(standardView.snp.bottom).offset(8)
			$0.bottom.equalToSuperview().inset(14)
			$0.leading.equalTo(colorButton).offset(-4)
			$0.trailing.equalTo(colorButton).offset(4)
			$0.height.equalTo(2)
		}
	}
}
