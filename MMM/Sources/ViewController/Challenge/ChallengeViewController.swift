//
//  ChallengeViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/09/07.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class ChallengeViewController: BaseViewController, View {
	typealias Reactor = ChallengeReactor

	// MARK: - Properties
	// MARK: - UI Components
	private lazy var stackView = UIStackView() // imageView, label
	private lazy var titleLabel = UILabel()
	private lazy var ivBust = UIImageView()
	private lazy var suggestionButton = UIButton()
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            if let rootVC = navigationController.viewControllers.first {
                let view = UIView(frame: .init(origin: .zero, size: .init(width: 150, height: 44)))
                
                rootVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
                rootVC.navigationItem.rightBarButtonItem = nil
            }
        }
    }
	
	func bind(reactor: ChallengeReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension ChallengeViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: ChallengeReactor) {
		// 기능 제안하기
		suggestionButton.rx.tap
			.withUnretained(self)
			.map { .didTapSuggestion }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: ChallengeReactor) {
		reactor.state
			.map { $0.isConnect }
			.distinctUntilChanged()
			.filter { $0 }
			.subscribe({ _ in
				if let url = URL(string: "https://forms.gle/7fq6DKP85G2L7KZHA") {
					UIApplication.shared.open(url)
				}
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension ChallengeViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		stackView = stackView.then {
			$0.axis = .vertical
			$0.alignment = .center
			$0.spacing = 16
			$0.distribution = .equalSpacing
		}
		
		titleLabel = titleLabel.then {
			let attrString = NSMutableAttributedString(string: "경제목표를 달성할 수 있는 서비스를 고민중이에요\n혹시 mmm에 원하시는 기능이 있으신가요?")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 4
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray600
			$0.textAlignment = .center
			$0.numberOfLines = 2
		}
		
		ivBust = ivBust.then {
			$0.image = R.Icon.empty04
			$0.contentMode = .scaleAspectFill
		}
		
		suggestionButton = suggestionButton.then {
			$0.setTitle("+ 기능 제안하기", for: .normal)
			$0.titleLabel?.font = R.Font.body1
			$0.backgroundColor = R.Color.black
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.layer.cornerRadius = 4
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(stackView)
		stackView.addArrangedSubviews(titleLabel, ivBust, suggestionButton)
	}
	
	override func setLayout() {
		super.setLayout()
		
		stackView.snp.makeConstraints {
			$0.horizontalEdges.equalToSuperview()
			$0.centerY.equalToSuperview()
		}
		
		ivBust.snp.makeConstraints {
			$0.width.equalTo(144)
		}
		
		suggestionButton.snp.makeConstraints {
			$0.height.equalTo(44)
			$0.horizontalEdges.equalToSuperview().inset(64)
		}
	}
}
