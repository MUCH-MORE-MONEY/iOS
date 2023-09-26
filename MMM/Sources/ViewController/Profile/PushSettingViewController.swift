//
//  PushSettingViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/23.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import UserNotifications

final class PushSettingViewController: BaseViewControllerWithNav, View {
    // MARK: - UI Components
    private lazy var newsPushStackView = UIStackView()
    private lazy var newsPushMainLabel = UILabel()
    private lazy var newsPushSwitch = UISwitch()
    private lazy var newsPushSubLabel = UILabel()
    
    private lazy var customPushStackView = UIStackView()
    private lazy var customPushMainLabel = UILabel()
    private lazy var customPushSwitch = UISwitch()
    private lazy var customPushSubLabel = UILabel()
    
    private lazy var customPushTimeSettingLabel = UILabel()
    private lazy var customPushTimeSettingView = CustomPushTimeSettingView()
    
    private lazy var customPushTextSettingLabel = UILabel()
    private lazy var customPushTextSettingView = CustomPushTextSettingView()
    
    private lazy var divider = UIView()
    // MARK: - Properties
    var reactor: PushSettingReactor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(reactor: reactor)
    }
    
    func bind(reactor: PushSettingReactor) {
        bindState(reactor)
        bindAction(reactor)
    }
}
//MARK: - Bind
extension PushSettingViewController {
    private func bindAction(_ reactor: PushSettingReactor) {
        
        // FIXME: -
        // 뷰 진입 시 최초 1회 실행 + 최초 진입시 앱 권한을 가져오기 위한 액션
        reactor.action.onNext(.viewAppear)
        
        // FIXME: - 네트워크 테스트 코드
        //        textSettingView.rx.tapGesture()
        //            .when(.recognized)
        //            .map { _ in .didTapTextSettingButton(PushReqDto(content: "test", pushAgreeDvcd: "01")) }
        //            .bind(to: reactor.action)
        //            .disposed(by: disposeBag)
        
        // 소식 일림 switch
        newsPushSwitch.rx.value
            .map { .newsPushSwitchToggle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 맞춤 알림 switch
        customPushSwitch.rx.value
            .map { .customPushSwitchToggle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 알림 시간 지정 버튼
        customPushTimeSettingView.rx.tapGesture()
            .when(.recognized)
            .map { _ in .didTapCustomPushTimeSettingView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 알림 문구 지정 버튼
        customPushTextSettingView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.presentBottomSheet()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: PushSettingReactor) {
        
        // FIXME: -
        // 뷰 최초 진입 시 알람 설정 메시지 띄우기 && 푸쉬 설정이 꺼져있으면 토글 false
        reactor.state
            .map { $0.isShowPushAlert }
            .distinctUntilChanged()
            .bind(onNext: showAlertMessage)
            .disposed(by: disposeBag)
                
        // FIXME: - 네트워크 테스트 코드
        //        reactor.state
        //            .compactMap { $0.pushMessage }
        ////            .filter { $0.pushMessage }
        //            .bind { [weak self] data in
        //                guard let self = self else { return }
        //                print("text Tapped \(data)")
        //            }
        //            .disposed(by: disposeBag)
        
        // 푸쉬 알림
        reactor.state
            .map { $0.isNewsPushSwitchOn }
            .distinctUntilChanged()
            .bind(onNext: configureNewsPushSwitch)
            .disposed(by: disposeBag)
        
        // 맞춤 알림 on 일때 버튼 활성화
        reactor.state
            .map { $0.isCustomPushSwitchOn }
            .distinctUntilChanged()
            .bind(onNext: configureCustomPushSwitch)
            .disposed(by: disposeBag)
        
        // 맞춤 알림 on && detail 화면 전환
        reactor.state
            .filter { $0.isCustomPushSwitchOn }
            .map { $0.isPresentDetailView }
            .filter { $0 }
            .bind(onNext: presentDetailViewController)
            .disposed(by: disposeBag)
        
        


    }
}

// MARK: - Actions
private extension PushSettingViewController {
    private func presentDetailViewController(_ isPresent: Bool) {
        let vc = PushSettingDetailViewController()
        vc.reactor = PushSettingDetailReactor(provider: ServiceProvider.shared)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAlertMessage(_ isPushOn: Bool) {
        let title = "앱 알림이 꺼져있어요"
        let message = "알림을 받기 위해 앱 알림을 켜주세요"
        
        if isPushOn {
            
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.showAlert(alertType: .canCancel, titleText: title, contentText: message, cancelButtonText: "닫기", confirmButtonText: "알림 켜기")
                self.newsPushSwitch.isOn = isPushOn
                self.customPushSwitch.isOn = isPushOn
                
                self.newsPushSwitch.isEnabled = false
                self.customPushSwitch.isEnabled = false
            }
        }
    }
    
    // 스위치 상태에 따른 버튼 비/활성화
    private func configureCustomPushSwitch(_ isOn: Bool) {
        self.customPushTextSettingView.configure(isOn)
        self.customPushTimeSettingView.configure(isOn)
        // UserDefaults에 현재 스위치 상태 값 저장
        Common.setCustomPushSwitch(isOn)
    }
    
    private func configureNewsPushSwitch(_ isOn: Bool) {
        Common.setNewsPushSwitch(isOn)
    }
    
    private func presentBottomSheet() {
        let vc = DateBottomSheetViewController(height: 360)
//        vc.reactor = CustomPushTextSettingReactor(provider: reactor.provider)
        self.present(vc, animated: true, completion: nil)
    }
}

extension PushSettingViewController {
    override func setAttribute() {
        title = "푸시 알림 설정"
        view.backgroundColor = R.Color.gray100
        
        newsPushStackView.addArrangedSubviews(newsPushMainLabel, newsPushSwitch)
        customPushStackView.addArrangedSubviews(customPushMainLabel, customPushSwitch)
        
        view.addSubviews(newsPushStackView, newsPushSubLabel, divider, customPushStackView, customPushSubLabel, customPushTimeSettingLabel, customPushTextSettingLabel, customPushTimeSettingView, customPushTextSettingView)
        
        
        newsPushStackView = newsPushStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        
        customPushStackView = customPushStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        
        newsPushMainLabel = newsPushMainLabel.then {
            $0.text = "이벤트 소식 알림"
            $0.font = R.Font.h5
            $0.textColor = R.Color.gray800
        }
        
        customPushMainLabel = customPushMainLabel.then {
            $0.text = "맞춤 정보 알림"
            $0.font = R.Font.h5
            $0.textColor = R.Color.gray800
        }
        
        newsPushSwitch = newsPushSwitch.then {
            $0.tintColor = R.Color.orange500
            $0.onTintColor = R.Color.orange500
            $0.isOn = Common.getNewsPushSwitch()
        }
        
        customPushSwitch = customPushSwitch.then {
            $0.tintColor = R.Color.orange500
            $0.onTintColor = R.Color.orange500
            $0.isOn = Common.getCustomPushSwitch()
        }
        
        divider = divider.then {
            $0.backgroundColor = R.Color.gray200
        }
        
        newsPushSubLabel = newsPushSubLabel.then {
            $0.text = "MMM가 보내는 다양한 이벤트와 정보를 받는 알림으로 맞춤 정보 알림과는 무관해요"
            $0.numberOfLines = 0
            $0.font = R.Font.body3
            $0.textColor = R.Color.gray800
        }
        
        customPushSubLabel = customPushSubLabel.then {
            $0.text = "원하는 시간에 가계부 관리하기 유용한 알림을 보낼게요."
            $0.numberOfLines = 0
            $0.font = R.Font.body3
            $0.textColor = R.Color.gray800
        }
        
        customPushTimeSettingLabel = customPushTimeSettingLabel.then {
            $0.text = "알림 시간 지정"
            $0.font = R.Font.title1
            $0.textColor = R.Color.gray800
        }
        
        customPushTextSettingLabel = customPushTextSettingLabel.then {
            $0.text = "알람 문구 지정"
            $0.font = R.Font.title1
            $0.textColor = R.Color.gray800
        }
        
        customPushTimeSettingView = customPushTimeSettingView.then {
            $0.layer.cornerRadius = 4
        }
        
        customPushTextSettingView = customPushTextSettingView.then {
            $0.layer.cornerRadius = 4
        }
    }
    
    override func setLayout() {
        newsPushStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        newsPushSubLabel.snp.makeConstraints {
            $0.top.equalTo(newsPushStackView.snp.bottom).offset(13)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(newsPushSubLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(1)
        }
        
        customPushStackView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        customPushSubLabel.snp.makeConstraints {
            $0.top.equalTo(customPushStackView.snp.bottom).offset(13)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        customPushTimeSettingLabel.snp.makeConstraints {
            $0.top.equalTo(customPushSubLabel.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        customPushTimeSettingView.snp.makeConstraints {
            $0.top.equalTo(customPushTimeSettingLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        customPushTextSettingLabel.snp.makeConstraints {
            $0.top.equalTo(customPushTimeSettingView.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        customPushTextSettingView.snp.makeConstraints {
            $0.top.equalTo(customPushTextSettingLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
    }
}

// FIXME: - Delegate -> Reactorkit 변경 예정
extension PushSettingViewController: CustomAlertDelegate {
    func didAlertCofirmButton() {
        // 16 이상 부터 알림 설정 딥링크 이동 가능
        if #available(iOS 16.0, *) {
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else { } // 딥링크 이동 실패
        } else { // 16미만 버전은 앱 설정 까지만 이동 가능
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else {  } // 딥링크 이동 실패
        }
    }
    
    func didAlertCacelButton() { }
}

