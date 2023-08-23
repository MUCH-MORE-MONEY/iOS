//
//  StatisticsSatisfactionSelectViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import Combine
import Then
import SnapKit
import ReactorKit

final class StatisticsSatisfactionSelectViewController: UIViewController, View {
	typealias Reactor = BottomSheetReactor

	enum Satisfaction: Int {
		case low	// 1~2점
		case middle	// 3점
		case hight	// 4~5점
	}
	
	// MARK: - Properties
	private var isDark: Bool = false
	private var satisfaction: Satisfaction
	weak var delegate: BottomSheetChild?
	var disposeBag: DisposeBag = DisposeBag()

	// MARK: - UI Components
	private lazy var stackView = UIStackView() // Title Label, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var checkButton = UIButton()
	
	init(satisfaction: Satisfaction) {
		self.satisfaction = satisfaction
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup() // 초기 셋업할 코드들
	}
	
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	func bind(reactor: BottomSheetReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension StatisticsSatisfactionSelectViewController {
	// 외부에서 설정
	func setData(title: String, isDark: Bool = false) {
		DispatchQueue.main.async {
			self.titleLabel.text = title
		}
		self.isDark = isDark
	}
}
//MARK: - Bind
extension StatisticsSatisfactionSelectViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: BottomSheetReactor) {
		// 확인 버튼
		checkButton.rx.tap
			.map { .didTapSatisfactionCheckButton(type: self.satisfaction.rawValue) }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: BottomSheetReactor) {
		reactor.state
			.map { $0.successBySatisfaction }
			.subscribe { [weak self] satisfaction in
				guard let self = self else { return }
				self.delegate?.willDismiss()
			}
			.disposed(by: disposeBag)
	}
}
//MARK: - Style & Layouts
private extension StatisticsSatisfactionSelectViewController {
	private func setAttribute() {
		self.view.backgroundColor = isDark ? R.Color.gray900 : .white
		
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.alignment = .center
			$0.distribution = .equalCentering
		}
		
		titleLabel = titleLabel.then {
			$0.text = "날짜 이동"
			$0.font = R.Font.h5
			$0.textColor = isDark ? R.Color.gray200 : R.Color.black
			$0.textAlignment = .left
		}
		
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
			$0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .right
			$0.titleLabel?.font = R.Font.title3
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
	}
	
	private func setLayout() {
		view.addSubviews(stackView)
		stackView.addArrangedSubviews(titleLabel, checkButton)
		
		stackView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(28)
		}
	}
}
