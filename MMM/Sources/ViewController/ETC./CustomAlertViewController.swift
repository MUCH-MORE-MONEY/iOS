//
//  CustomAlertViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/03.
//

import UIKit

// Custom Alert의 버튼의 액션을 처리하는 Delegate
@objc
protocol CustomAlertDelegate: AnyObject {
	func didAlertCofirmButton()   // confirm button event
	func didAlertCacelButton()     // cancel button event
    @objc optional func handleTap()
}

extension CustomAlertDelegate where Self: UIViewController {
	func showAlert(
		alertType: AlertType,
		titleText: String,
		contentText: String,
		cancelButtonText: String? = "취소하기",
		confirmButtonText: String
	) {
		let vc = CustomAlertViewController()
		
		vc.delegate = self
		
		vc.modalPresentationStyle = .overFullScreen
		vc.modalTransitionStyle = .crossDissolve		// 뷰가 전환될 때의 효과
		vc.setData(alertType: alertType, titleText: titleText, contentText: contentText, cancelButtonText: cancelButtonText, confirmButtonText: confirmButtonText)
		
		self.present(vc, animated: true, completion: nil)
	}
}

enum AlertType {
	case onlyConfirm    // 확인 버튼
	case canCancel      // 확인 + 취소 버튼
}

final class CustomAlertViewController: UIViewController {
	
	weak var delegate: CustomAlertDelegate?
	
	private lazy var alertType: AlertType = .canCancel

	private lazy var bgView = UIView().then {
		$0.backgroundColor = R.Color.black.withAlphaComponent(0.7)
	}
	
	private lazy var alertView = UIView().then {
		$0.backgroundColor = R.Color.white
		$0.layer.cornerRadius = 16
	}
	
	// (title & content)와 buttonStackView
	private lazy var containerStackView1 = UIStackView().then {
		$0.axis = .vertical
		$0.spacing = 16
		$0.alignment = .center
	}
	
	// title 과 content
	private lazy var containerStackView2 = UIStackView().then {
		$0.axis = .vertical
		$0.spacing = 8
		$0.alignment = .center
	}
	
	private lazy var buttonStackView = UIStackView().then {
		$0.spacing = 11
		$0.distribution = .fillEqually
	}

	private lazy var titleLabel = UILabel().then {
		$0.font = R.Font.title1
		$0.textColor = R.Color.black
		$0.textAlignment = .center
		$0.numberOfLines = 0
	}
	
	private lazy var contentLabel = UILabel().then {
		$0.font = R.Font.body1
		$0.textColor = R.Color.gray700
		$0.textAlignment = .center
		$0.numberOfLines = 0
	}
	
	private lazy var cancelButton = UIButton().then {
		$0.setTitle("취소하기", for: .normal)
		$0.setTitleColor(R.Color.black, for: .normal)	// enable
		$0.titleLabel?.font = R.Font.body1
		$0.backgroundColor = R.Color.white
		$0.setBackgroundColor(R.Color.gray200, for: .highlighted)
		$0.layer.borderWidth = 1
		$0.layer.borderColor = R.Color.gray200.cgColor
		$0.layer.cornerRadius = 4
		$0.addTarget(self, action: #selector(didTapCancleButton), for: .touchUpInside)
	}
	
	private lazy var confirmButton = UIButton().then {
		$0.setTitle("확인하기", for: .normal)
		$0.setTitleColor(R.Color.white, for: .normal)
		$0.titleLabel?.font = R.Font.title3
		$0.backgroundColor = R.Color.gray900
		$0.setBackgroundColor(R.Color.gray600, for: .highlighted)
		$0.layer.cornerRadius = 4
		$0.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setUp()		// 초기 셋업할 코드들
    }
}

//MARK: - Action
extension CustomAlertViewController {
	
	public func setData(alertType: AlertType, titleText: String, contentText: String, cancelButtonText: String? = "취소하기", confirmButtonText: String) {
		self.alertType = alertType
		self.titleLabel.text = titleText
		
		let attributedString = NSMutableAttributedString(string: contentText)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakStrategy = .hangulWordPriority
		paragraphStyle.lineSpacing = 2
		paragraphStyle.alignment = .center
		attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
		self.contentLabel.attributedText = attributedString
		
		self.cancelButton.setTitle(cancelButtonText, for: .normal)
		self.confirmButton.setTitle(confirmButtonText, for: .normal)
	}
	
	// 확인
	@objc private func didTapConfirmButton() {
		self.dismiss(animated: true) {
            self.delegate?.didAlertCofirmButton()
        }
	}
	
	// 취소
	@objc private func didTapCancleButton() {
		self.dismiss(animated: true) { self.delegate?.didAlertCacelButton() }
	}
	
	// 배경 클릭
	@objc func handleTap(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true) { self.delegate?.handleTap?() }
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CustomAlertViewController {
	private func setUp() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		view.backgroundColor = R.Color.black.withAlphaComponent(0.2)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		bgView.addGestureRecognizer(tapGesture)
		
		switch alertType {
		case .onlyConfirm:
			cancelButton.isHidden = true
			
			confirmButton.isHidden = false
			buttonStackView.addArrangedSubview(confirmButton)
		case .canCancel:
			cancelButton.isHidden = false
			
			confirmButton.isHidden = false
			[cancelButton, confirmButton].forEach {
				buttonStackView.addArrangedSubview($0)
			}
		}
		
		view.addSubviews(bgView, alertView)
		[titleLabel, contentLabel].forEach {
			containerStackView2.addArrangedSubview($0)
		}
		
		[containerStackView2, buttonStackView].forEach {
			containerStackView1.addArrangedSubview($0)
		}
		alertView.addSubview(containerStackView1)
	}
	
	private func setLayout() {
		
		bgView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		alertView.snp.makeConstraints {
			$0.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide)
			$0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
			$0.left.right.equalToSuperview().inset(24)
			$0.centerY.equalToSuperview()
		}
		
		containerStackView1.snp.makeConstraints {
			$0.top.equalTo(alertView.snp.top).inset(24)
			$0.bottom.equalTo(alertView.snp.bottom).inset(24)
			$0.left.equalTo(alertView.snp.left).inset(20)
			$0.right.equalTo(alertView.snp.right).inset(20)
		}
		
		containerStackView2.snp.makeConstraints {
			$0.left.right.equalToSuperview()
		}
		
		switch alertType {
		case .onlyConfirm:
			confirmButton.snp.makeConstraints {
				$0.width.equalTo(containerStackView2.snp.width)
				$0.height.equalTo(40)
			}

		case .canCancel:
			cancelButton.snp.makeConstraints {
				$0.width.greaterThanOrEqualTo(containerStackView2.snp.width).multipliedBy(0.48)
				$0.height.equalTo(40)
			}
		}
	}
}
