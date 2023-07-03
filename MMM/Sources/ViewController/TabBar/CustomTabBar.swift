//
//  CustomTabBar.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/18.
//

import UIKit
import Then
import SnapKit
import Combine
import SwiftUI
import FirebaseAnalytics

final class CustomTabBar: UIView {
	
	// MARK: - UI Components
	private let tabBarStackView = UIStackView().then {
		$0.axis = .horizontal
		$0.distribution = .fillEqually
		$0.alignment = .fill
		$0.backgroundColor = R.Color.gray100
		$0.layer.shadowOpacity = 0.7
		$0.layer.shadowOffset = CGSize(width: 0, height: 1)
		$0.layer.shadowRadius = 1
		$0.layer.masksToBounds = false
	}
	
	let tabItems: [TabItem]
	public var tabButtons = [UIButton]()
	public var plusButton = UIButton()
	
	@Published var selectedIndex = 0
	private var cancellable = Set<AnyCancellable>()
	
	init(tabItems: [TabItem]) {
		self.tabItems = tabItems
		super.init(frame: .zero)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		setAttribute()
		setLayout()
		bind()
	}
	
    // 뷰 바깥의 영역도 터치가 가능하도록 하는 코드
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let convertedButtonPoint = plusButton.convert(point, from: self)
        let convertedstackViewPoint = tabBarStackView.convert(point, to: self)
        return plusButton.point(inside: convertedButtonPoint, with: event) || tabBarStackView.point(inside: convertedstackViewPoint, with: event)
    }

	private func setAttribute() {
		plusButton = plusButton.then {
			$0.setImage(R.Icon.iconPlus, for: .normal)
		}
        
		tabItems
			.enumerated()
			.forEach { i, item in
				var button = UIButton()
				
				if item == .add {
					
				} else {
					button = button.then {
						$0.setTitleColor(R.Color.gray900, for: .normal)
						$0.layer.shadowRadius = 0
						$0.contentVerticalAlignment = .top
						$0.setImage(item.image, for: .normal)
						$0.setImage(item.selectedImage, for: .highlighted)
                        $0.contentMode = .scaleAspectFit
                        
						$0.setTitle(item.rawValue, for: .normal)
						$0.setTitleColor(R.Color.gray500, for: .normal)
						$0.titleLabel?.font = R.Font.body5

						$0.alignTextBelow(spacing: 7) // image & text spacing
						$0.contentEdgeInsets = UIEdgeInsets(top: 27, left: 0, bottom: 0, right: 0)
                        // icon 크기 : 24
                        // text 크기 : 12
                        // padding : 7
					}
				}
				
				tabButtons.append(button)
				tabBarStackView.addArrangedSubview(button)
			}
		addSubviews(tabBarStackView, plusButton)
	}
	
	private func setLayout() {
		tabBarStackView.snp.makeConstraints {
			$0.top.left.right.bottom.equalToSuperview()
		}
		
		plusButton.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(tabBarStackView.snp.top).offset(-16)
		}
	}
	
	private func bind() {
		// 탭 버튼이 클릭되었을 때 selectedIndex 변경
		tabButtons
			.enumerated()
			.forEach { i, item in
				item.tapPublisher
					.sinkOnMainThread { [weak self] in
						guard let self = self else { return }
						self.selectedIndex = i
					}
					.store(in: &cancellable)
			}
		plusButton.tapPublisher
			.sinkOnMainThread { [weak self] in
				guard let self = self else { return }
				self.selectedIndex = 1
                
			}.store(in: &cancellable)
		// selectedIndex에 따른 탭바 버튼 포커싱 UI를 변경
		$selectedIndex
			.receive(on: DispatchQueue.main)
			.sinkOnMainThread { [weak self] index in
				guard let self = self else { return }
				if index == 1 {
					
				} else {
					tabItems
						.enumerated()
						.forEach { i, item in
							let isButtonSelected = index == i
							let image = isButtonSelected ? item.selectedImage : item.image
							let titleColor = isButtonSelected ? R.Color.gray900 : R.Color.gray500
							let font = isButtonSelected ? R.Font.body4 : R.Font.body5
							let selectedButton = self.tabButtons[i]
							
							if item != .add {
								selectedButton.setImage(image, for: .normal)
								selectedButton.setTitleColor(titleColor, for: .normal)
								selectedButton.titleLabel?.font = font
							}
							
						}
				}
			}.store(in: &cancellable)
	}
}
