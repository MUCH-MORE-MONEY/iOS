//
//  StatisticsBudgetView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import Then
import SnapKit
import UIKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsBudgetView: BaseView, View {
	// MARK: - Constants
	private enum UI {
		static let titleLabelTop: CGFloat = 6
		static let skTitleBottom: CGFloat = 16
	}
	
	enum State {
		case less	// 더 적음
		case more	// 더 많음
		case over	// 매우 많음
		
		var title: String {
			switch self {
			case .less: return "예산보다 적게 지출하고 있어요 "
			case .more: return "적정소비보다 더 지출하고 있어요 "
			case .over: return "예산보다 많이 지출하고 있어요"
			}
		}
		
		var subTitle: String {
			switch self {
			case .less: return "이렇게만 지출하면 당신도 저축왕!"
			case .more: return "예산을 위해 오늘의 지출을 줄여봐요"
			case .over: return "다음 달은 조금 더 힘내볼까요? "
			}
		}
		
		var textColor: UIColor {
			switch self {
			case .less: return R.Color.black
			case .more: return R.Color.white
			case .over: return R.Color.white
			}
		}
		
		var barColor: UIColor {
			switch self {
			case .less: return R.Color.yellow600
			case .more: return R.Color.yellow800
			case .over: return R.Color.black
			}
		}
	}
	// MARK: - Properties
	private lazy var state: State = .less
	private let totalWidth: CGFloat = UIScreen.width - 24 * 2
	private let monthList: [CGFloat] = [0, 30, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	private var standardLeading: CGFloat {
		return setDate()
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var subTitleLabel = UILabel()
	private lazy var imageView = UIImageView() // Boost 아이콘
	private lazy var totalBarView = UIView()
	private lazy var currentBarView = UIView()
	private lazy var percentLabel = UILabel()
	private lazy var currentPayLabel = UILabel()	// 현재 지출
	private lazy var separatorView = UIView()
	private lazy var settingBudgetLabel = UILabel()	// 예산
	private lazy var settingButton = UIButton()		// 설정
	private lazy var standardView = UIView()
	private lazy var standardLabel = UILabel()
	private lazy var dotLine = UIView()	// 점선

	// 스켈레톤 UI
	private lazy var skTitleView = UIView()
	private lazy var rangeLayer = CAGradientLayer()
	private lazy var titleLayer = CAGradientLayer()

	override func layoutSubviews() {
		super.layoutSubviews()
		
		rangeLayer.frame = subTitleLabel.bounds
		rangeLayer.cornerRadius = 4
		
		titleLayer.frame = skTitleView.bounds
		titleLayer.cornerRadius = 4
	}
	
	func bind(reactor: StatisticsReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension StatisticsBudgetView {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsReactor) {
		
		settingButton.rx.tap
			.map { .didTapNewTitleView }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {
		
		reactor.state
			.map { $0.percent }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: setPerent) // 그래프 값 변경
			.disposed(by: disposeBag)
		
	}
}
//MARK: - Action
extension StatisticsBudgetView {
	// 외부에서 설정
	func setBudget(estimatedEarning: Int) {
		self.settingBudgetLabel.text = "예산 \(estimatedEarning.withCommas()) 원"
	}
	
	// 외부에서 설정
	func setCurrentPay(currentPayLabel: Int) {
		self.currentPayLabel.text = "현재 \(currentPayLabel.withCommas()) 원"
	}
	
	func setPerent(percent: Int) {
		let percent = 40
		self.percentLabel.text = "\(percent)%"
		
//		let percent = percent > 100 ? 100 : percent
		let cal = totalWidth * Double(percent) / 100.0
		
		self.currentBarView.snp.updateConstraints {
			$0.width.equalTo(cal)
		}
		
		// 11% 미만일때, Text 위치 변경
		if percent < 11 {
			percentLabel.snp.remakeConstraints {
				$0.centerY.equalTo(currentBarView)
				$0.leading.equalTo(currentBarView.snp.trailing).offset(6)
			}
		} else {
			percentLabel.snp.remakeConstraints {
				$0.centerY.equalTo(currentBarView)
				$0.trailing.equalTo(currentBarView).offset(-6)
			}
		}
	}
	
	func isLoading(_ isLoading: Bool) {
		titleLabel.isHidden = isLoading
		imageView.isHidden = isLoading
		
		skTitleView.isHidden = !isLoading
		rangeLayer.isHidden = !isLoading
		titleLayer.isHidden = !isLoading
	}
	
	//MARK: 임시 주석 (예산 업데이트로 인해 빠짐) - Text 부분적으로 Bold 처리
//	private func setSubTextBold() -> NSMutableAttributedString {
//		let attributedText1 = NSMutableAttributedString(string: "부스트와 함께\n")
//		let attributedText2 = NSMutableAttributedString(string: "만족하는 경제습관 ")
//		let attributedText3 = NSMutableAttributedString(string: "만들기!")
//		
//		// 일반 Text 속성
//		let paragraphStyle = NSMutableParagraphStyle()
//		paragraphStyle.lineSpacing = 4
//		let textAttributes1: [NSAttributedString.Key : Any] = [
//			.font: R.Font.body1,
//			.foregroundColor: R.Color.white,
//			.paragraphStyle: paragraphStyle
//		]
//		
//		// Bold Text 속성
//		let textAttributes2: [NSAttributedString.Key : Any] = [
//			.font: R.Font.title3,
//			.foregroundColor: R.Color.white
//		]
//		
//		attributedText1.addAttributes(textAttributes1, range: NSMakeRange(0, attributedText1.length))
//		attributedText2.addAttributes(textAttributes2, range: NSMakeRange(0, attributedText2.length))
//		attributedText3.addAttributes(textAttributes1, range: NSMakeRange(0, attributedText3.length))
//		
//		attributedText1.append(attributedText2)
//		attributedText1.append(attributedText3)
//		return attributedText1
//	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsBudgetView: SkeletonLoadable {
	// 초기 셋업할 코드들
	override func setup() {
		super.setup()
		
		setDotLine()
	}
	
	func setDate(date: Date = Date(), isLast: Bool = false) -> CGFloat {
		let month = Int(date.getFormattedDate(format: "MM")) ?? 1
		let day = isLast ? monthList[month] : CGFloat((Int(date.getFormattedDate(format: "dd")) ?? 1)) - 1
		let totalDay = monthList[month] - 1
		let padding: CGFloat = 5 * 2
		let leading = (totalWidth - padding) / totalDay * day
		return leading
	}
	
	func setDotLine() {
		let layer = CAShapeLayer()
		layer.strokeColor = R.Color.black.cgColor
		layer.lineDashPattern = [2, 2]

		let path = UIBezierPath()
		let point1 = CGPoint(x: dotLine.frame.midX, y: dotLine.frame.minY)
		let point2 = CGPoint(x: dotLine.frame.midX, y: dotLine.frame.maxY)
		
		path.move(to: point1)
		path.addLine(to: point2)
		
		layer.path = path.cgPath
		dotLine.layer.addSublayer(layer)
	}
	
	func setStandard() {
		let month = Int(Date().getFormattedDate(format: "MM")) ?? 1
		let day = Int(Date().getFormattedDate(format: "dd")) ?? 1
		let totalDay = monthList[month]
		let padding: CGFloat = 5 * 2
		let leading = (totalWidth - padding) / totalDay * CGFloat(day)
		
		print("여기", totalWidth, totalDay, CGFloat(day), leading)
	}
	
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		let firstGroup = makeAnimationGroup(startColor: R.Color.gray800, endColor: R.Color.gray600)
		firstGroup.beginTime = 0.0
		rangeLayer = rangeLayer.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(firstGroup, forKey: "backgroundColor")
		}
		
		titleLayer = titleLayer.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(firstGroup, forKey: "backgroundColor")
		}
		
		skTitleView = skTitleView.then {
			$0.isHidden = true // 임시: 다음 배포
			$0.frame = .init(origin: .zero, size: .init(width: 164, height: 24))
			$0.layer.addSublayer(titleLayer)
		}
		
		titleLabel = titleLabel.then {
			$0.text = state.title
			$0.font = R.Font.prtendard(family: .bold, size: 16)
			$0.textColor = R.Color.gray200
		}
		
		subTitleLabel = subTitleLabel.then {
			$0.text = state.subTitle
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray300
			$0.layer.addSublayer(rangeLayer)
		}
		
		imageView = imageView.then {
			$0.image = R.Icon.characterHappy
			$0.contentMode = .scaleAspectFit
		}
		
		totalBarView = totalBarView.then {
			$0.layer.cornerRadius = 4
			$0.backgroundColor = R.Color.yellow100
		}
		
		currentBarView = currentBarView.then {
			$0.layer.cornerRadius = 4
			$0.backgroundColor = state.barColor
		}
		
		standardLabel = standardLabel.then {
			$0.text = "적정지출"
			$0.textColor = R.Color.white
			$0.font = R.Font.body5
			$0.clipsToBounds = true // cornerRadius 적용
			$0.layer.cornerRadius = 10
			$0.textAlignment = .center
			$0.backgroundColor = R.Color.black
		}
		
		dotLine = dotLine.then {
			$0.frame = .init(x: 0, y: 0, width: 1, height: 39)
		}

		percentLabel = percentLabel.then {
			$0.text = "0%"
			$0.textColor = state.textColor
			$0.font = R.Font.body4
		}
		
		currentPayLabel = currentPayLabel.then {
			$0.text = "현재 지출 0원"
			$0.textColor = R.Color.yellow300
			$0.font = R.Font.body3
		}
		
		separatorView = separatorView.then {
			$0.backgroundColor = R.Color.gray700
		}
		
		settingBudgetLabel = settingBudgetLabel.then {
			$0.text = "예산 0원"
			$0.textColor = R.Color.yellow050
			$0.font = R.Font.body3
		}
		
		settingButton = settingButton.then {
			$0.setTitle("설정", for: .normal)
			$0.setTitleColor(R.Color.gray500, for: .normal)
			$0.titleLabel?.font = R.Font.body3
			$0.configuration?.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10) // touch 영역 늘리기
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(titleLabel, subTitleLabel, imageView, skTitleView, totalBarView, currentBarView, percentLabel, standardView, currentPayLabel, separatorView, settingBudgetLabel, settingButton)
		standardView.addSubviews(standardLabel, dotLine)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(10)
			$0.leading.equalToSuperview()
		}
		
		subTitleLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(4)
			$0.leading.equalToSuperview()
		}
		
		imageView.snp.makeConstraints {
			$0.leading.lessThanOrEqualTo(titleLabel.snp.trailing)
			$0.top.trailing.equalToSuperview()
		}
		
		skTitleView.snp.makeConstraints {
			$0.bottom.equalToSuperview().inset(UI.skTitleBottom)
			$0.leading.equalToSuperview()
			$0.width.equalTo(164)
			$0.height.equalTo(24)
		}
		
		totalBarView.snp.makeConstraints {
			$0.top.equalTo(subTitleLabel.snp.bottom).offset(30)
			$0.horizontalEdges.equalToSuperview()
			$0.height.equalTo(22)
		}
		
		currentBarView.snp.makeConstraints {
			$0.top.leading.equalTo(totalBarView)
			$0.width.equalTo(totalWidth * 0.5)
			$0.height.equalTo(22)
		}
		
		percentLabel.snp.makeConstraints {
			$0.centerY.equalTo(currentBarView)
			$0.trailing.equalTo(currentBarView).offset(-6)
		}
		
		standardView.snp.makeConstraints {
			$0.leading.equalTo(totalBarView).offset(standardLeading)
			$0.bottom.equalTo(totalBarView)
			$0.width.equalTo(63)
			$0.height.equalTo(49)
		}
		
		standardLabel.snp.makeConstraints {
			$0.top.leading.trailing.equalToSuperview()
			$0.width.equalToSuperview()
			$0.height.equalTo(22)
		}
		
		dotLine.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(5)
			$0.top.equalToSuperview().inset(10)
			$0.bottom.equalToSuperview()
		}
		
		currentPayLabel.snp.makeConstraints {
			$0.top.equalTo(percentLabel.snp.bottom).offset(13)
			$0.leading.equalToSuperview()
		}
		
		separatorView.snp.makeConstraints {
			$0.centerY.equalTo(currentPayLabel)
			$0.leading.equalTo(currentPayLabel.snp.trailing).offset(10)
			$0.width.equalTo(1)
			$0.height.equalTo(9)
		}
		
		settingBudgetLabel.snp.makeConstraints {
			$0.top.equalTo(currentPayLabel)
			$0.leading.equalTo(separatorView.snp.trailing).offset(10)
		}
		
		settingButton.snp.makeConstraints {
			$0.centerY.equalTo(currentPayLabel)
			$0.trailing.equalToSuperview()
			$0.leading.greaterThanOrEqualTo(settingBudgetLabel.snp.trailing).offset(10)
		}
	}
}
