//
//  AddImageView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/23.
//

import UIKit
import Combine
import Then
import SnapKit

class AddImageView: UIView {
    private lazy var stackView = UIStackView()
    private lazy var cameraImageView = UIImageView()
    private lazy var addButton = UIButton()
    
    private lazy var cancellable = Set<AnyCancellable>()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        addSubviews(stackView)
        stackView.addArrangedSubviews(cameraImageView, addButton)
        
        stackView = stackView.then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.distribution = .fillProportionally
        }
        
        cameraImageView = cameraImageView.then {
            $0.image = R.Icon.camera48
        }
        
        addButton = addButton.then {
            $0.setTitle("사진 추가", for: .normal)
//            $0.titleEdgeInsets = UIEdgeInsets(top: 5,left: 24,bottom: 5,right: 24)
            $0.titleLabel?.font = R.Font.body4
            $0.setTitleColor(R.Color.gray500, for: .normal)
            $0.setButtonLayer()
            $0.backgroundColor = R.Color.gray100
            $0.layer.borderColor = R.Color.gray500.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(30)
            $0.left.right.equalToSuperview().inset(117)
        }
    }
    
    private func bind() {
        addButton.tapPublisher.sinkOnMainThread(receiveValue: didTapAddButton)
            .store(in: &cancellable)
    }
}

// MARK: - Action
extension AddImageView {
    func didTapAddButton() {
        print("Tapped")
    }
}
