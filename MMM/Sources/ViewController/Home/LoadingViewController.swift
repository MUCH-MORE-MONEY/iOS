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
	private lazy var loadingLottie: LottieAnimationView = LottieAnimationView(name: "loading")
	
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
//MARK: - Style & Layouts
private extension LoadingViewController {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		view.backgroundColor = R.Color.black.withAlphaComponent(0.3)
		
		loadingLottie = loadingLottie.then {
			$0.play()
			$0.contentMode = .scaleAspectFit
			$0.loopMode = .loop // 애니메이션을 무한으로 실행
			$0.backgroundColor = R.Color.black.withAlphaComponent(0.3)
			$0.isHidden = true
		}
	}
	
	private func setLayout() {
		view.addSubviews(loadingLottie)
		
		loadingLottie.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
