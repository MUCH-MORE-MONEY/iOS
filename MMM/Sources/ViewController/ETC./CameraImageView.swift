//
//  DefaultImageView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/12.
//

import UIKit
import SnapKit
import Then
import Combine

final class CameraImageView: UIView {
    // MARK: - UI Components
    private lazy var view = UIView()
    private lazy var cameraButton = UIButton()
    
    // MARK: - Properties
    private lazy var cancallable = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - Attribute & Hierarchy & Layouts
extension CameraImageView {
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func bind() {
        cameraButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapCameraButton)
            .store(in: &cancallable)

    }
    
    private func setAttribute() {
        addSubviews(view)
        view.addSubviews(cameraButton)
        
        view = view.then {
            $0.backgroundColor = R.Color.gray200
        }
        
        cameraButton = cameraButton.then {
            $0.setImage(R.Icon.camera48, for: .normal)
            $0.isEnabled = false
        }
    }
    
    private func setLayout() {
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        cameraButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}

// MARK: - Action
extension CameraImageView {
    func isCameraButtonActive(_ flag: Bool) {
        cameraButton.isEnabled = flag
    }
    
    func didTapCameraButton() {
        print("Camera Button")
    }
}
