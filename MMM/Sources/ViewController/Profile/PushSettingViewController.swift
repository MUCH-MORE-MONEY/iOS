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

final class PushSettingViewController: BaseViewController, View {
    // MARK: - UI Components
    private lazy var newsPushStackView = UIStackView()
    private lazy var newsPushMainLabel = UILabel()
    private lazy var newsPushSwitch = UISwitch()
    private lazy var newsPushSubLabel = UILabel()
    
    private lazy var customPushStackView = UIStackView()
    private lazy var customPushMainLabel = UILabel()
    private lazy var customPushSwitch = UISwitch()
    private lazy var customPushSubLabel = UILabel()
    
    private lazy var timeSettingLabel = UILabel()
    private lazy var timeSettingView = TimeSettingView()
    
    private lazy var textSettingLabel = UILabel()
    private lazy var textSettingView = TextSettingView()
    
    private lazy var divider = UIView()
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    var reactor: PushSettingReactor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind(reactor: reactor)
    }
    
    func bind(reactor: PushSettingReactor) {
        bindState(reactor)
        bindAction(reactor)
    }
}

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
        timeSettingView.rx.tapGesture()
            .when(.recognized)
            .map { _ in .didTapTimeSettingButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 알림 문구 지정 버튼
        textSettingView.rx.tapGesture()
            .when(.recognized)
            .map { _ in .didTapTextSettingButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: PushSettingReactor) {
        
        // FIXME: -
        // 뷰 최초 진입 시 알람 설정 메시지 띄우기
        reactor.state
            .map { $0.isShowPushAlert }
            .distinctUntilChanged()
            .filter { !$0 }
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
        
        //        reactor.state
        //            .subscribe(on: MainScheduler.instance)
        //            .map { $0.isEventSwitchOn }
        //            .bind { [weak self] data in
        //                guard let self = self else { return }
        //                self.eventSwitch.isOn = data
        //            }
        //            .disposed(by: disposeBag)
        
        
        
        //        reactor.state
        //            .filter { !$0.isInit }
        //            .map { $0.pushList }
        //            .filter { !$0.isEmpty }
        //            .bind { [weak self] list in
        //                guard let self = self else { return }
        //                self.eventSwitch.isOn = list[0].pushAgreeYN == "Y" ? true : false
        //                self.infoSwitch.isOn = list[1].pushAgreeYN == "Y" ? true : false
        //
        //            }
        //            .disposed(by: disposeBag)
        
        
        // 맞춤 알림 on 일때 버튼 활성화
        reactor.state
            .map { $0.isCustomPushSwitchOn }
            .bind(onNext: configureViews)
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
        vc.reactor = PushSettingDetailReactor()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAlertMessage(_ isFirst: Bool) {
        let title = "앱 알림이 꺼져있어요"
        let message = "알림을 받기 위해 앱 알림을 켜주세요"
        
        DispatchQueue.main.async {
            self.showAlert(alertType: .canCancel, titleText: title, contentText: message, cancelButtonText: "닫기", confirmButtonText: "알림 켜기")
        }
    }
    
    // 스위치 상태에 따른 버튼 비/활성화
    private func configureViews(_ isOn: Bool) {
        self.textSettingView.configure(isOn)
        self.timeSettingView.configure(isOn)
    }
}

private extension PushSettingViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }

    private func setAttribute() {
        title = "푸시 알림 설정"
        
        newsPushStackView.addArrangedSubviews(newsPushMainLabel, newsPushSwitch)
        customPushStackView.addArrangedSubviews(customPushMainLabel, customPushSwitch)
        
        view.addSubviews(newsPushStackView, newsPushSubLabel, divider, customPushStackView, customPushSubLabel, timeSettingLabel, textSettingLabel, timeSettingView, textSettingView)

        
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
        
        timeSettingLabel = timeSettingLabel.then {
            $0.text = "알림 시간 지정"
            $0.font = R.Font.title1
            $0.textColor = R.Color.gray800
        }
        
        textSettingLabel = textSettingLabel.then {
            $0.text = "알람 문구 지정"
            $0.font = R.Font.title1
            $0.textColor = R.Color.gray800
        }
        
        timeSettingView = timeSettingView.then {
            $0.layer.cornerRadius = 4
        }
        
        textSettingView = textSettingView.then {
            $0.layer.cornerRadius = 4
        }
    }
    
    private func setLayout() {
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
        
        timeSettingLabel.snp.makeConstraints {
            $0.top.equalTo(customPushSubLabel.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        timeSettingView.snp.makeConstraints {
            $0.top.equalTo(timeSettingLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        textSettingLabel.snp.makeConstraints {
            $0.top.equalTo(timeSettingView.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }

        textSettingView.snp.makeConstraints {
            $0.top.equalTo(textSettingLabel.snp.bottom).offset(12)
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
