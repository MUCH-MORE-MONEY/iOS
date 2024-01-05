//
//  LoadingViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/06/15.
//

import UIKit
import Lottie
import Then
import SnapKit

final class LoadingViewController: UIViewController {
	// MARK: - Properties
	lazy var isPresent: Bool = false
	
	// MARK: - UI Components
	private lazy var stackView = UIStackView()
	private lazy var loadingLottie: LottieAnimationView = LottieAnimationView(name: "loading")
	private lazy var descriptionLabel = UILabel()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		self.isPresent = false
	}
}
//MARK: - Action
extension LoadingViewController {
	// 외부에서 입력
	func setLabel(label: String) {
		descriptionLabel = descriptionLabel.then {
			$0.text = label
			$0.font = R.Font.title1
			$0.textColor = R.Color.white
		}
		
		DispatchQueue.main.async {
			self.stackView.addArrangedSubviews(self.descriptionLabel)
		}
	}
	
	func play() {
		DispatchQueue.main.async {
			self.loadingLottie.play()
			self.loadingLottie.isHidden = false
		}
	}
	
	func stop() {
		self.loadingLottie.stop()
		self.loadingLottie.isHidden = true
	}
	
	func isHidden() -> Bool {
		return isPresent
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension LoadingViewController {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		
		stackView = stackView.then {
			$0.axis = .vertical
			$0.spacing = -16
			$0.distribution = .fill
			$0.alignment = .center
		}
		
		loadingLottie = loadingLottie.then {
			$0.play()
			$0.contentMode = .scaleAspectFit
			$0.loopMode = .loop // 애니메이션을 무한으로 실행
			$0.isHidden = true
		}
	}
	
	private func setLayout() {
		view.addSubviews(stackView)
		stackView.addArrangedSubviews(loadingLottie)
		
		stackView.snp.makeConstraints {
			$0.centerX.centerY.equalToSuperview()
		}
	}
}
