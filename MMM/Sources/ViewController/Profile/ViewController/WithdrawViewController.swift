//
//  WithdrawViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/04.
//

import UIKit

final class WithdrawViewController: UIViewController {

	private lazy var backButton = UIBarButtonItem()

	private lazy var reconfirmLabel = UILabel()

	private lazy var economicLabel = UILabel()
	
	private lazy var moneyLabel = UILabel()

	private lazy var containView = UIView()
	
	private lazy var containerStackView = UIStackView()
	
	private lazy var checkLabel = UILabel()
	
	private lazy var firstComfirm = WithdrawConfirmView()

	private lazy var secondComfirm = WithdrawConfirmView()
	
	private lazy var confirmStackView = UIStackView()
	
	private lazy var confirmButton = UIButton()
	
	private lazy var confirmLabel = UILabel()
	
	private lazy var withdrawButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}

	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)	// navigation bar 노출
	}
}

//MARK: - Action
extension WithdrawViewController: CustomAlertDelegate {
	@objc func didTapBackButton(_ sender: UITapGestureRecognizer) {
		navigationController?.popViewController(animated: true)
	}
	
	// 확인 버튼 이벤트 처리
	func didAlertCofirmButton() { }
	
	// 취소 버튼 이벤트 처리
	func didAlertCacelButton() { }
}

//MARK: - Style & Layouts
extension WithdrawViewController {
	
	private func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		navigationItem.leftBarButtonItem = backButton
		navigationItem.title = "회원탈퇴"
		
		backButton = backButton.then {
			$0.image = R.Icon.arrowBack24
			$0.style = .plain
			$0.target = self
			$0.action = #selector(didTapBackButton)
		}
		
		reconfirmLabel = reconfirmLabel.then {
			$0.text = "정말 탈퇴하시겠어요?"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
		}
		
		economicLabel = economicLabel.then {
			$0.text = "이대로 가면 작성했던 {nnn}개의 경재활동,"
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.gray800
		}
		
		moneyLabel = moneyLabel.then {
			$0.text = "그리고 모았던 {nn,nnn,nnn}원이 사라져요."
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.gray800
		}
		
		containView = containView.then {
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 16
		}
		
		containerStackView = containerStackView.then {
			$0.axis = .vertical
			$0.spacing = 16
			$0.alignment = .leading
//			$0.distribution = .fillProportionally
		}
		
		checkLabel = checkLabel.then {
			$0.text = "탈퇴하기 전 확인해주세요"
			$0.font = R.Font.title1
			$0.textColor = R.Color.gray900
		}
		
		firstComfirm = firstComfirm.then {
			$0.setUp(number: "1", title: "30일동안은 기록이 유지돼요.", content: "회원님의 탈퇴는 30일 이후에 처리가 되며 30일 이전 재가입할 시 복구가 가능해요.")
		}
		
		secondComfirm = secondComfirm.then {
			$0.setUp(number: "2", title: "30일 이후에는 모든 기록이 사라져요.", content: "30일 뒤에 모든 데이터는 회원님의 소중한 정보를 지키기 위해 개인정보 처리 방침에 따라 복구가 불가능해요.")
		}
		
		confirmStackView = confirmStackView.then {
			$0.axis = .horizontal
			$0.spacing = 12
			$0.alignment = .center
		}
		
		confirmButton = confirmButton.then {
			$0.setImage(R.Icon.checkInActive, for: .normal)
			$0.setImage(R.Icon.checkActive, for: .selected)
			$0.setBackgroundColor(R.Color.white, for: .normal)
			$0.setBackgroundColor(R.Color.gray900, for: .selected)
			$0.layer.cornerRadius = 4
//			$0.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
		}
		
		confirmLabel = confirmLabel.then {
			$0.text = "안내사항을 확인했으며, 이에 동의합니다"
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray800
		}
		
		withdrawButton = withdrawButton.then {
			$0.setTitle("MMM 탈퇴하기", for: .normal)
			$0.titleLabel?.font = R.Font.title1
			$0.backgroundColor = R.Color.gray900
			$0.layer.cornerRadius = 4
			$0.layer.shadowColor = UIColor.black.cgColor
			$0.layer.shadowOpacity = 0.25
			$0.layer.shadowOffset = CGSize(width: 0, height: 2)
			$0.layer.shadowRadius = 8
//			$0.addTarget(self, action: #selector(presentShareSheet), for: .touchUpInside)
		}
		
		view.addSubviews(reconfirmLabel, economicLabel, moneyLabel, containView, confirmStackView, withdrawButton)
		containView.addSubviews(containerStackView)
		[checkLabel, firstComfirm, secondComfirm].forEach {
			containerStackView.addArrangedSubview($0)
		}
		
		[confirmButton, confirmLabel].forEach {
			confirmStackView.addArrangedSubview($0)
		}
	}
	
	private func setLayout() {
		reconfirmLabel.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(32)
			$0.left.equalTo(view.safeAreaLayoutGuide).inset(24)
		}
		
		economicLabel.snp.makeConstraints {
			$0.top.equalTo(reconfirmLabel.snp.bottom).offset(12)
			$0.left.equalTo(view.safeAreaLayoutGuide).inset(24)
		}
		
		moneyLabel.snp.makeConstraints {
			$0.top.equalTo(economicLabel.snp.bottom).offset(8)
			$0.left.equalTo(view.safeAreaLayoutGuide).inset(24)
		}
		
		containView.snp.makeConstraints {
			$0.top.equalTo(moneyLabel.snp.bottom).offset(48)
			$0.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
			$0.height.equalTo(242)
		}
		
		containerStackView.snp.makeConstraints {
			$0.top.left.bottom.equalToSuperview().inset(16)
			$0.right.equalToSuperview().inset(35)
		}
		
		firstComfirm.snp.makeConstraints {
			$0.height.equalTo(66)
		}
		
		secondComfirm.snp.makeConstraints {
			$0.height.equalTo(86)
		}
		
		confirmStackView.snp.makeConstraints {
			$0.top.equalTo(containView.snp.bottom).offset(24)
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
