//
//  HomeOnboardingViewController.swift
//  MMM
//
//  Created by geonhyeong on 4/9/24.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class HomeOnboardingViewController: BaseViewController, View {
	typealias Reactor = HomeReactor

	// MARK: - Properties
	// MARK: - UI Components
	private lazy var imageView: UIImageView = .init()
	private lazy var titleLabel: UILabel = .init()
	private lazy var contentLabel: UILabel = .init()
	
	init(image: UIImage?, title: String, content: String) {
		super.init(nibName: nil, bundle: nil)
		self.imageView.image = image
		self.titleLabel.text = title
		self.contentLabel.text = content
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(reactor: HomeReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension HomeOnboardingViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: HomeReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: HomeReactor) {
	}
}
//MARK: - Action
extension HomeOnboardingViewController {
}
//MARK: - Attribute & Hierarchy & Layouts
extension HomeOnboardingViewController {
	override func setAttribute() {
		super.setAttribute()
		
		imageView = imageView.then {
			$0.image = imageView.image
			$0.sizeToFit()
		}
		
		titleLabel = titleLabel.then {
			$0.text = titleLabel.text
			$0.textColor = R.Color.black
			$0.font = R.Font.title1
		}
		
		contentLabel = contentLabel.then {
			$0.text = contentLabel.text
			$0.textColor = R.Color.gray700
			$0.font = R.Font.body3
			$0.textAlignment = .center
			$0.numberOfLines = 2
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(imageView, titleLabel, contentLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		imageView.snp.makeConstraints {
			$0.top.horizontalEdges.equalToSuperview()
			$0.height.equalTo(172)
		}
		
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(imageView.snp.bottom).offset(38)
		}
		
		contentLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(titleLabel.snp.bottom).offset(12)
		}
	}
}
