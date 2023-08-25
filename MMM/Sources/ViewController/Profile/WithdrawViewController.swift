//
//  WithdrawViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/04.
//

import UIKit
import Combine
import Lottie

final class WithdrawViewController: BaseViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel: ProfileViewModel
	
	// MARK: - UI Components
	private lazy var reconfirmLabel = UILabel()
	private lazy var defaultLabel = UILabel() // 이대로 가면 작성했던
	private lazy var economicLabel = UILabel()
	private lazy var moneyLabel = CountAnimationStackView()
	private lazy var containView = UIView()
	private lazy var containerStackView = UIStackView()
	private lazy var checkLabel = UILabel()
	private lazy var firstComfirm = WithdrawConfirmView()
	private lazy var secondComfirm = WithdrawConfirmView()
	private lazy var confirmStackView = UIStackView()
	private lazy var confirmButton = UIButton()
	private lazy var confirmLabel = UILabel()
	private lazy var withdrawButton = UIButton()
	private lazy var loadView = LoadingViewController()

	init(viewModel: ProfileViewModel) {
		self.viewModel = viewModel
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
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel.summary = nil // Text가 남아있는 문제 해결
		viewModel.isWidrawError = nil // 값이 변경되어 있는 문제 해결
	}
}
//MARK: - Action
extension WithdrawViewController: CustomAlertDelegate {
	// toggle
	func didTapConfirmButton() {
		if confirmButton.isSelected {
			confirmButton.setImage(R.Icon.checkInActive, for: .normal)
			confirmButton.backgroundColor = R.Color.white
			withdrawButton.isEnabled = false
			withdrawButton.titleLabel?.font = R.Font.prtendard(family: .medium, size: 18)
			withdrawButton.backgroundColor = R.Color.gray400
		} else {
			confirmButton.setImage(R.Icon.checkActive, for: .normal)
			confirmButton.backgroundColor = R.Color.gray900
			withdrawButton.isEnabled = true
			withdrawButton.titleLabel?.font = R.Font.title1
			withdrawButton.backgroundColor = R.Color.gray900
		}
		confirmButton.isSelected = !confirmButton.isSelected
	}
	
	// 경제 활동 요약
	func setSummary(_ recordCnt: Int, _ recordSumAmount: Int) {
		economicLabel = economicLabel.then {
			$0.attributedText = setMutiText(isMoney: false, first: "", count: recordCnt, second: "의 경제활동과")
			$0.numberOfLines = 0
		}
		
		moneyLabel = moneyLabel.then {
			$0.setData(first: "", second: "이 사라져요.", money: recordSumAmount, unitText: "원", duration: 0.1)
		}
	}
	
	// Alert 탈퇴하기
	func didTapWithdrawButton() {
		self.showAlert(alertType: .canCancel, titleText: "정말 탈퇴하시겠어요?", contentText: "탈퇴하면 소장 중인 데이터가 삭제되며 30일 이후에는 복구가 불가능합니다.", confirmButtonText: "탈퇴하기")
	}
	
	// 화면전환
	func processWidrow() {
		if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
			viewModel.withdraw() // 탈퇴
			sceneDelegate.window?.rootViewController = sceneDelegate.onboarding
			DispatchQueue.main.asyncAfter(deadline: .now()) {
				sceneDelegate.onboarding.showAlert(alertType: .onlyConfirm, titleText: "탈퇴를 완료하였습니다", contentText: "언제든 다시 MMM을 찾아와주세요!", confirmButtonText: "확인하기")
			}
		}
	}
	
	/// 네트워크 오류시 Toast 노출
//	func showToast() {
//		let toastView = ToastView(toastMessage: "일시적인 오류가 발생했습니다.")
//		toastView.setSnackAttribute()
//
//		self.view.addSubview(toastView)
//
//		toastView.snp.makeConstraints {
//			$0.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
//			$0.bottom.equalTo(withdrawButton.snp.top).offset(-16)
//			$0.height.equalTo(40)
//		}
//
//		toastView.toastAnimation(duration: 1.0, delay: 3.0, option: .curveEaseOut)
//	}
	
	// 확인 버튼 이벤트 처리
	func didAlertCofirmButton() {
		viewModel.withdraw() // 회원 탈퇴
	}
	
	// 취소 버튼 이벤트 처리
	func didAlertCacelButton() { }
}

//MARK: - Style & Layouts
extension WithdrawViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		fetch()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		confirmButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapConfirmButton)
			.store(in: &cancellable)
		
		withdrawButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapWithdrawButton)
			.store(in: &cancellable)
		
		//MARK: output
		viewModel.$summary
			.sinkOnMainThread(receiveValue: { [weak self] summary in
				guard let summary = summary, let recordCnt = summary.recordCnt, let recordSumAmount = summary.recordSumAmount else { return }
				
				self?.setSummary(recordCnt, recordSumAmount)
			}).store(in: &cancellable)
		
//		viewModel.$isLoading
//			.sinkOnMainThread(receiveValue: { [weak self] loading in
//				guard let self = self else { return }
//
//				if loading && !self.loadView.isPresent {
//					self.loadView.play()
//					self.loadView.isPresent = true
//					self.loadView.modalPresentationStyle = .overFullScreen
//					self.present(self.loadView, animated: false)
//				} else {
//					self.loadView.dismiss(animated: false)
//				}
//			}).store(in: &cancellable)
		
		viewModel.$isWithdraw
			.sinkOnMainThread(receiveValue: { [weak self] loading in
				guard let self = self, let loading = loading else { return }
				
				if loading && !self.loadView.isPresent {
					self.loadView.play()
					self.loadView.isPresent = true
					self.loadView.modalPresentationStyle = .overFullScreen
					self.present(self.loadView, animated: false)
				} else {
					self.loadView.dismiss(animated: false)
				}
			}).store(in: &cancellable)
		
		viewModel.$isWidrawError
			.sinkOnMainThread(receiveValue: { [weak self] isError in
				guard let self = self, let isError = isError else { return }
				if isError {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.window?.showToast(message: "일시적인 오류가 발생했습니다.")
                    }
                } // 네트워크 에러 발생
			}).store(in: &cancellable)
	}
	
	private func fetch() {
		viewModel.getSummary() // 경제활동 요약
	}
	
	private func setMutiText(isMoney: Bool, first: String, count: Int, second: String) -> NSMutableAttributedString {
		let attributedText1 = NSMutableAttributedString(string: first)
		
		var attributedText2: NSMutableAttributedString
		if isMoney {
			attributedText2 = NSMutableAttributedString(string: "\(count.withCommas())원")
		} else {
			attributedText2 = NSMutableAttributedString(string: "\(count)개")
		}
		
		let attributedText3 = NSMutableAttributedString(string: second)

		let textAttributes: [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.font: R.Font.prtendard(family: .medium, size: 16),
			NSAttributedString.Key.foregroundColor: R.Color.gray800
		]
		
		attributedText1.addAttributes(textAttributes, range: NSMakeRange(0, attributedText1.length))
				
		let textAttributes2: [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.font: R.Font.prtendard(family: .medium, size: 16),
			NSAttributedString.Key.foregroundColor: R.Color.orange500
		]
		attributedText2.addAttributes(textAttributes2, range: NSMakeRange(0, attributedText2.length))
		attributedText3.addAttributes(textAttributes, range: NSMakeRange(0, attributedText3.length))
		attributedText1.append(attributedText2)
		attributedText1.append(attributedText3)
		return attributedText1
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		navigationItem.title = "회원탈퇴"
		
		reconfirmLabel = reconfirmLabel.then {
			$0.text = "정말 탈퇴하시겠어요?"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
		}
		
		containView = containView.then {
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 16
		}
		
		containerStackView = containerStackView.then {
			$0.axis = .vertical
			$0.spacing = 16
			$0.alignment = .leading
			$0.distribution = .fill
		}
		
		defaultLabel = defaultLabel.then {
			$0.text = "이대로 가면 작성했던"
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.gray800
		}
		
		checkLabel = checkLabel.then {
			$0.text = "탈퇴하기 전 확인해주세요"
			$0.font = R.Font.title1
			$0.textColor = R.Color.gray900
		}
		
		firstComfirm = firstComfirm.then {
			$0.setData(number: "1", title: "30일동안은 기록이 유지돼요.", content: "회원님의 탈퇴는 30일 이후에 처리가 되며\n30일 이전 재가입할 시 복구가 가능해요.")
		}
		
		secondComfirm = secondComfirm.then {
			$0.setData(number: "2", title: "30일 이후에는 모든 기록이 사라져요.", content: "30일 뒤에 모든 데이터는 회원님의 소중한\n정보를 지키기 위해 개인정보 처리 방침에 따라\n복구가 불가능해요.")
		}
		
		confirmStackView = confirmStackView.then {
			$0.axis = .horizontal
			$0.spacing = 12
			$0.alignment = .center
		}
		
		confirmButton = confirmButton.then {
			$0.setImage(R.Icon.checkInActive, for: .normal)
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 4
		}
		
		confirmLabel = confirmLabel.then {
			$0.text = "안내사항을 확인했으며, 이에 동의합니다"
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray800
		}
		
		withdrawButton = withdrawButton.then {
			$0.setTitle("MMM 탈퇴하기", for: .normal)
			$0.titleLabel?.font = R.Font.prtendard(family: .medium, size: 18)
			$0.isEnabled = false
			$0.backgroundColor = R.Color.gray400
			$0.layer.cornerRadius = 4
			$0.layer.shadowColor = UIColor.black.cgColor
			$0.layer.shadowOpacity = 0.25
			$0.layer.shadowOffset = CGSize(width: 0, height: 2)
			$0.layer.shadowRadius = 8
		}
	}
	
	private func setLayout() {
		view.addSubviews(reconfirmLabel, defaultLabel, economicLabel, moneyLabel, containView, confirmStackView, withdrawButton)
		containView.addSubviews(containerStackView)
		containerStackView.addArrangedSubviews(checkLabel, firstComfirm, secondComfirm)
		confirmStackView.addArrangedSubviews(confirmButton, confirmLabel)
		
		reconfirmLabel.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
			$0.left.equalTo(view.safeAreaLayoutGuide).inset(24)
		}
		
		defaultLabel.snp.makeConstraints {
			$0.top.equalTo(reconfirmLabel.snp.bottom).offset(12)
			$0.left.equalTo(view.safeAreaLayoutGuide).inset(24)
		}
		
		economicLabel.snp.makeConstraints {
			$0.top.equalTo(defaultLabel.snp.bottom).offset(8)
			$0.left.equalTo(view.safeAreaLayoutGuide).inset(24)
		}
		
		moneyLabel.snp.makeConstraints {
			$0.top.equalTo(economicLabel.snp.bottom).offset(8)
			$0.left.equalTo(view.safeAreaLayoutGuide).inset(24)
		}
		
		containView.snp.makeConstraints {
			$0.top.greaterThanOrEqualTo(moneyLabel.snp.bottom).offset(24)
			$0.left.right.equalToSuperview().inset(24)
		}
		
		containerStackView.snp.makeConstraints {
			$0.edges.equalToSuperview().inset(16)
		}
		
		firstComfirm.snp.makeConstraints {
			$0.height.greaterThanOrEqualTo(66)
		}

		secondComfirm.snp.makeConstraints {
			$0.height.greaterThanOrEqualTo(90)
		}
		
		confirmStackView.snp.makeConstraints {
			$0.top.equalTo(containView.snp.bottom).offset(27)
			$0.left.right.equalTo(view.safeAreaLayoutGuide).inset(75)
		}
		
		confirmButton.snp.makeConstraints {
			$0.width.height.equalTo(24)
		}
		
		withdrawButton.snp.makeConstraints {
			$0.left.right.equalToSuperview().inset(24)
			$0.bottom.equalToSuperview().inset(58)
			$0.height.equalTo(56)
		}
	}
}
