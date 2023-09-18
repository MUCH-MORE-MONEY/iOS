//
//  DetailPageControl.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/16.
//

import UIKit
import SnapKit
import Then
import Combine

final class BottomPageControlView: UIView {
	// MARK: - UI Components
	lazy var previousButton = UIButton().then {
		$0.setImage(R.Icon.arrowBackBlack24, for: .normal)
		var disableImage = R.Icon.arrowBackBlack24?.withTintColor(R.Color.gray200)
		$0.setImage(disableImage, for: .disabled)
	}
	
	lazy var nextButton = UIButton().then {
		$0.setImage(R.Icon.arrowNextBlack24, for: .normal)
		var disableImage = R.Icon.arrowNextBlack24?.withTintColor(R.Color.gray200)
		$0.setImage(disableImage, for: .disabled)
	}
	
	private lazy var indexLabel = UILabel().then {
		$0.textColor = R.Color.black
		$0.font = R.Font.body1
		$0.text = "0 / 0"
	}
	
	private lazy var stackView = UIStackView().then {
		$0.axis = .horizontal
		$0.distribution = .equalCentering
		$0.alignment = .center
	}
	
	// MARK: - Properties
	
	var index: Int = 0 {
		didSet {
			previousButton.isEnabled = index == 0 ? false : true
			nextButton.isEnabled = index == economicActivityId.count-1 ? false : true
		}
	}
	private var economicActivityId: [String] = []
	private var viewModel: HomeDetailViewModel?
	private lazy var cancellable = Set<AnyCancellable>()

	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension BottomPageControlView {
	private func setup() {
		setAttribute()
		setLayout()
		bind()
	}
	
	private func bind() {
		nextButton.tapPublisher.sinkOnMainThread(receiveValue: didTapNextButton)
			.store(in: &cancellable)
		
		previousButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapPreviousButton)
			.store(in: &cancellable)
	}
	
	private func setAttribute() {
		addSubviews(stackView)
		stackView.addArrangedSubviews(previousButton, indexLabel, nextButton)
	}
	
	private func setLayout() {
		stackView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(16)
			$0.left.right.bottom.equalToSuperview()
		}
		
		indexLabel.snp.makeConstraints {
			$0.centerY.equalTo(nextButton.snp.centerY)
		}
	}
}

// MARK: - Action
extension BottomPageControlView {
	func didTapPreviousButton() {
		if index != 0 {
			index -= 1
            viewModel?.pageIndex = index
			updateView()
		}
	}
	
	func didTapNextButton() {
		if index != economicActivityId.count-1 {
			index += 1
            viewModel?.pageIndex = index
			updateView()
		}
	}
	
	func updateView() {
		let idSize = economicActivityId.count
		indexLabel.text = "\(index+1) / \(idSize)"
		let id = economicActivityId[index]
		viewModel?.fetchDetailActivity(id: id)
	}
	
	func setViewModel(_ viewModel: HomeDetailViewModel, _ economicActivityId: [String]) {
		self.viewModel = viewModel
		self.economicActivityId = economicActivityId
        self.index = viewModel.pageIndex
		let idSize = economicActivityId.count
		indexLabel.text = "\(index+1) / \(idSize)"
	}
}
