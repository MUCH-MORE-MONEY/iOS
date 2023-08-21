//
//  StatisticsViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/14.
//

import UIKit
import Then
import SnapKit

final class StatisticsViewController: UIViewController {
	// MARK: - Properties
	private var tabBarViewModel: TabBarViewModel
	
	// MARK: - UI Components

	init(tabBarViewModel: TabBarViewModel) {
		self.tabBarViewModel = tabBarViewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
}
//MARK: - Action
extension StatisticsViewController {
}
//MARK: - Style & Layouts
extension StatisticsViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		// MARK: input
	}
	
	private func setAttribute() {
	}
	
	private func setLayout() {
	}
}
