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

class CustomTabBar: UIView {
    
    // MARK: - UI Components
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.backgroundColor = R.Color.gray100
    }
    
    let tabItems: [TabItem]
    public var tabButtons = [UIButton]()
    
    @Published var currentIndex = 0
    private var cancellable = Set<AnyCancellable>()
    private var selectedIndex = 0 {
        didSet { updateUI() }
    }
    
    init(tabItems: [TabItem]) {
        self.tabItems = tabItems
        super.init(frame: .zero)
        //        setup()
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func updateUI() {
        tabItems
            .enumerated()
            .forEach { i, item in
                let isButtonSelected = selectedIndex == i
                let image = isButtonSelected ? item.selectedImage : item.image
                let selectedButton = tabButtons[i]
                
                selectedButton.setImage(image, for: .normal)
                selectedButton.setImage(image?.alpha(0.5), for: .highlighted)
            }
    }
    
    private func setAttribute() {
        tabItems
            .enumerated()
            .forEach{ i, item in
                let button = UIButton()
                
                button.setImage(item.image, for: .normal)
                button.setImage(item.selectedImage, for: .highlighted)
                button.setTitle(item.rawValue, for: .normal)
                button.setTitleColor(R.Color.gray900, for: .normal)
                button.semanticContentAttribute = .forceRightToLeft
                
                //                button.addAction { [weak self] in
                //                    self?.selectedIndex = i
                //                }
                
                tabButtons.append(button)
                stackView.addArrangedSubview(button)
                
                if item == .add {
                    stackView.addArrangedSubview(UIButton())
                    stackView.removeArrangedSubview(button)
                    stackView.addSubviews(button)
                }
            }
        addSubviews(stackView)
    }
    
    private func setUp() {
        defer { updateUI() }
        
        tabItems
            .enumerated()
            .forEach { i, item in
                let button = UIButton()
                button.setImage(item.image, for: .normal)
                button.setImage(item.image?.alpha(0.5), for: .highlighted)
                button.addAction { [weak self] in
                    self?.selectedIndex = i
                }
                tabButtons.append(button)
                stackView.addArrangedSubview(button)
            }
        
        backgroundColor = .systemGray.withAlphaComponent(0.2)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        tabButtons[1].snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(-16)
        }
    }
    
    private func bind() {
        tabButtons
            .enumerated()
            .forEach { i, item in
                item.tapPublisher
                    .sinkOnMainThread { [weak self] in
                        guard let self = self else { return }
                        self.currentIndex = i
                        print(self.currentIndex)
                        
                        let isButtonSelected = self.currentIndex == i
                        let image = isButtonSelected ? self.tabItems[i].selectedImage : self.tabItems[i].image
                        let selectedButton = self.tabButtons[i]
                        
                        selectedButton.setImage(image, for: .normal)
                    }
                    .store(in: &cancellable)
            }
    }
}
