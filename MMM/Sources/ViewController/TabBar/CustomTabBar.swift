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

class CustomTabBar: UIView {
    
    // MARK: - UI Components
    private let tabBarStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.backgroundColor = R.Color.gray100
    }
    
    let tabItems: [TabItem]
    public var tabButtons = [UIButton]()
    
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
    
    private func setAttribute() {
        
        tabItems
            .enumerated()
            .forEach { i, item in
                var button = UIButton().then {
                    $0.setImage(item.image, for: .normal)
                    $0.setImage(item.selectedImage, for: .highlighted)
                    $0.setTitleColor(R.Color.gray900, for: .normal)
//                    $0.setBackgroundColor(R.Color.blue300, for: .normal)
                }
                
                if item == .add {
                    
                } else {
                    button = button.then {
                        $0.setTitle(item.rawValue, for: .normal)
                        $0.setTitleColor(R.Color.gray500, for: .normal)
                        $0.titleLabel?.font = R.Font.body5
                        $0.alignTextBelow(spacing: 4)
                    }
                }
                
                tabButtons.append(button)
                tabBarStackView.addArrangedSubview(button)
            }
        addSubviews(tabBarStackView)
    }
    
    private func setLayout() {
        tabBarStackView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        tabButtons[1].snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(-26)
        }
    }
    
    private func bind() {
        tabButtons
            .enumerated()
            .forEach { i, item in
                item.tapPublisher
                    .sinkOnMainThread { [weak self] in
                        guard let self = self else { return }
                        self.selectedIndex = i
                        print(self.selectedIndex)
                    }
                    .store(in: &cancellable)
            }
        
        $selectedIndex
            .receive(on: DispatchQueue.main)
            .sinkOnMainThread { [weak self] index in
                guard let self = self else { return }
                tabItems
                    .enumerated()
                    .forEach { i, item in
                        let isButtonSelected = index == i
                        let image = isButtonSelected ? item.selectedImage : item.image
                        let titleColor = isButtonSelected ? R.Color.gray900 : R.Color.gray500
                        let font = isButtonSelected ? R.Font.body4 : R.Font.body5
                        let selectedButton = self.tabButtons[i]

                        selectedButton.setImage(image, for: .normal)
                        selectedButton.setTitleColor(titleColor, for: .normal)
                        selectedButton.titleLabel?.font = font
                    }
            }.store(in: &cancellable)
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIviewControllerType = TabBarController
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        TabBarController(widgetIndex: 0)
    }
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
    }
}
