//
//  OnBoardingPageViewController.swift
//  MMM
//
//  Created by geonhyeong on 4/9/24.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class OnBoardingPageViewController: BaseViewController, View {
	typealias Reactor = HomeReactor
	// MARK: - Properties
	private lazy var pages: [UIViewController] = []
	private lazy var pageControll: UIPageControl = UIPageControl()
	private lazy var currentIndex = 0 { // currentIndex가 변할때마다 pageControll.currentPage 값을 변경
		didSet {
			pageControll.currentPage = currentIndex
		}
	}
	
	// MARK: - UI Components
	private lazy var bgView: UIView = .init()
	private lazy var contentView: UIView = .init()
	private lazy var pageVC: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	private lazy var nextBtn: UIButton = .init()
	private lazy var finishBtn: UIButton = .init()
	
	func bind(reactor: HomeReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension OnBoardingPageViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: HomeReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: HomeReactor) {
		nextBtn.rx.tap
			.subscribe(onNext: nextStep)
			.disposed(by: disposeBag)
		
		finishBtn.rx.tap
			.subscribe(onNext: finishStep)
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension OnBoardingPageViewController {
	// 다음 Step으로 넘어가기
	func nextStep() {
		self.currentIndex += 1
		self.pageVC.setViewControllers([pages[currentIndex]], direction: .forward, animated: true)
		
		if currentIndex == pages.count - 1 {
			self.showFinishButton()
		} else {
			self.hideFinishButton()
		}
	}
	
	// Popup 닫기
	func finishStep() {
		dismiss(animated: true)
	}
	
	func showFinishButton() {
		nextBtn.isHidden = true
		finishBtn.isHidden = false
	}
	
	func hideFinishButton() {
		nextBtn.isHidden = false
		finishBtn.isHidden = true
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension OnBoardingPageViewController {
	override func setup() {
		setMakeView()
		super.setup()
	}
	
	func setMakeView() {
		let view1 = HomeOnboardingViewController(image: R.Icon.iconPopup01, title: "가계부 작성은 왜 해야 할까요?", content: "mmm과 함께 가계부를 적을 때\n어떤 좋은 점들이 있는지 알려드릴게요")
		let view2 = HomeOnboardingViewController(image: R.Icon.iconPopup02, title: "먼저, 나의 경제 패턴을 알 수 있어요", content: "작성한 경제활동들을 카테고리별로\n정리하여 어떻게 쓰고 있는지 파악해요")
		let view3 = HomeOnboardingViewController(image: R.Icon.iconPopup03, title: "같은 돈이라도 더 잘 소비할 수 있어요", content: "월별 통계를 통해 나의 경제활동에 대한\n평가를 스스로 해보며 판단하는 힘이 생겨요")
		let view4 = HomeOnboardingViewController(image: R.Icon.iconPopup04, title: "끝으로, 나의 경제 목표 달성에 가까이!", content: "mmm이 체계적인 관리를 통해\n원하는 꿈을 이룰 수 있도록 도와줄거에요.")

		pages.append(view1)
		pages.append(view2)
		pages.append(view3)
		pages.append(view4)
	}
	
	override func setAttribute() {
		super.setAttribute()
				
		bgView = bgView.then {
			$0.backgroundColor = R.Color.black
			$0.alpha = 0.7
		}
		
		contentView = contentView.then {
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 16
		}
		
		pageVC = pageVC.then {
			$0.setViewControllers([pages[currentIndex]], direction: .forward, animated: false)
			$0.view.isUserInteractionEnabled = false // Scroll 방지
		}
		
		pageControll = pageControll.then {
			$0.currentPageIndicatorTintColor = R.Color.orange500
			$0.pageIndicatorTintColor = R.Color.gray200
			$0.numberOfPages = pages.count
			$0.currentPage = currentIndex
			$0.isUserInteractionEnabled = false // Touch 방지
		}
		
		nextBtn = nextBtn.then {
			$0.setTitle("다음", for: .normal)
			$0.backgroundColor = R.Color.gray900
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.titleLabel?.font = R.Font.body2
			$0.layer.cornerRadius = 4
		}
		
		finishBtn = finishBtn.then {
			$0.setTitle("닫기", for: .normal)
			$0.backgroundColor = R.Color.gray900
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.titleLabel?.font = R.Font.body2
			$0.layer.cornerRadius = 4
			$0.isHidden = true // 첫 Step에 숨기기
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()

		view.addSubviews(bgView, contentView)
		contentView.addSubviews(pageVC.view, pageControll, nextBtn, finishBtn)
	}
	
	override func setLayout() {
		super.setLayout()
		
		bgView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		contentView.snp.makeConstraints {
			$0.width.equalTo(312)
			$0.height.equalTo(392)
			$0.center.equalToSuperview()
		}
		
		pageControll.snp.makeConstraints {
			$0.top.equalToSuperview().inset(203)
			$0.horizontalEdges.equalToSuperview()
		}
		
		pageVC.view.snp.makeConstraints {
			$0.edges.equalToSuperview().inset(24)
		}
		
		nextBtn.snp.makeConstraints {
			$0.bottom.horizontalEdges.equalTo(pageVC.view)
			$0.height.equalTo(40)
		}
		
		finishBtn.snp.makeConstraints {
			$0.bottom.horizontalEdges.equalTo(pageVC.view)
			$0.height.equalTo(40)
		}
	}
}
