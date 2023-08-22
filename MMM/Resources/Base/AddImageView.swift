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
    private lazy var backgroundView = UIView()
    private lazy var stackView = UIStackView()
    private lazy var cameraImageView = UIImageView()
    private lazy var addButton = UIButton()
    
    private lazy var cancellable = Set<AnyCancellable>()
    
    var viewModel: EditActivityViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension AddImageView {
    // MARK: - Style & Layout
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func setAttribute() {
        addSubviews(backgroundView)
        backgroundView.addSubviews(stackView)
        stackView.addArrangedSubviews(cameraImageView, addButton)
        
        backgroundView = backgroundView.then {
            $0.backgroundColor = R.Color.gray200
            $0.layer.cornerRadius = 4
        }
        
        stackView = stackView.then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.distribution = .fillProportionally
        }
        
        cameraImageView = cameraImageView.then {
            $0.image = R.Icon.camera48
            $0.contentMode = .scaleAspectFit
        }
        
        addButton = addButton.then {
            $0.setTitle("사진 추가", for: .normal)
            $0.contentEdgeInsets = UIEdgeInsets(top: 5,left: 24,bottom: 5,right: 24)
            $0.titleLabel?.font = R.Font.body4
            $0.setTitleColor(R.Color.gray500, for: .normal)
            $0.layer.cornerRadius = 4
            $0.backgroundColor = R.Color.gray200
            $0.layer.borderColor = R.Color.gray300.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    private func setLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width-24*2)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func bind() {
        addButton.tapPublisher
            .sinkOnMainThread {
                if let viewModel = self.viewModel {
                    viewModel.didTapAddButton = true
                }
            }.store(in: &cancellable)
    }
    
    func setData(viewModel: EditActivityViewModel) {
        self.viewModel = viewModel
    }
}
