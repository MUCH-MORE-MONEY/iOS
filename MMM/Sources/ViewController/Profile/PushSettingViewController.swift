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

final class PushSettingViewController: BaseViewController, View {
    // MARK: - UI Components
    private lazy var eventPushStackView = UIStackView()
    private lazy var infoPushStackView = UIStackView()
    private lazy var divider = UIView()
    private lazy var eventMainLabel = UILabel()
    private lazy var infoMainLabel = UILabel()
    private lazy var eventSwitch = UISwitch()
    private lazy var infoSwitch = UISwitch()
    private lazy var eventSubLabel = UILabel()
    private lazy var infoSubLabel = UILabel()
    private lazy var timeSettingLabel = UILabel()
    private lazy var textSettingLabel = UILabel()
    
    private lazy var timeSettingView = TimeSettingView()
    private lazy var textSettingView = TextSettingView()
    
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
        
        // 뷰 진입 시 최초 1회 실행
        reactor.action.onNext(.viewAppear)
        
        timeSettingView.rx.tapGesture()
            .when(.recognized)
            .map { _ in .didTapTimeSettingButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // FIXME: - 네트워크 테스트 코드
        textSettingView.rx.tapGesture()
            .when(.recognized)
            .map { _ in .didTapTextSettingButton(PushReqDto(content: "test", pushAgreeDvcd: "01")) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // event switch
        eventSwitch.rx.value
            .map { .eventSwitchToggle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
            
        // info switch
        infoSwitch.rx.value
            .map { .infoSwitchToggle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(_ reactor: PushSettingReactor) {
        
        // 뷰 최초 진입 시 알람 설정 메시지 띄우기
        reactor.state
            .map { $0.isInit }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: showAlertMessage)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .filter { $0.isInfoSwitchOn }
            .filter { $0.isPresentTimeDetail }
            .bind { [weak self] _ in
                guard let self = self else { return }
                let vc = PushSettingDetailViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
        
        reactor.state
            .map { $0.isEventSwitchOn }
            .bind { [weak self] data in
                guard let self = self else { return }
                self.eventSwitch.isOn = data
            }
            .disposed(by: disposeBag)
        
        
        
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
        
        reactor.state
            .map { $0.isInfoSwitchOn }
            .bind { [weak self] data in
                guard let self = self else { return }
                self.textSettingView.configure(data)
                self.timeSettingView.configure(data)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions
private extension PushSettingViewController {
    private func showAlertMessage(_ isFirst: Bool) {
        let title = "앱 알림이 꺼져있어요"
        let message = "알림을 받기 위해 앱 알림을 켜주세요"
        
        showAlert(alertType: .canCancel, titleText: title, contentText: message, cancelButtonText: "닫기", confirmButtonText: "알림 켜기")
    }
}

private extension PushSettingViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    
    private func setAttribute() {
        title = "푸시 알림 설정"
        
        eventPushStackView.addArrangedSubviews(eventMainLabel, eventSwitch)
        infoPushStackView.addArrangedSubviews(infoMainLabel, infoSwitch)
        
        view.addSubviews(eventPushStackView, eventSubLabel, divider, infoPushStackView, infoSubLabel, timeSettingLabel, textSettingLabel, timeSettingView, textSettingView)
        
        eventPushStackView = eventPushStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        
        infoPushStackView = infoPushStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        
        eventMainLabel = eventMainLabel.then {
            $0.text = "이벤트 소식 알림"
            $0.font = R.Font.h5
            $0.textColor = R.Color.gray800
        }
        
        infoMainLabel = infoMainLabel.then {
            $0.text = "맞춤 정보 알림"
            $0.font = R.Font.h5
            $0.textColor = R.Color.gray800
        }
        
        eventSwitch = eventSwitch.then {
            $0.tintColor = R.Color.orange500
            $0.onTintColor = R.Color.orange500
            $0.isOn = false
        }
        
        infoSwitch = infoSwitch.then {
            $0.tintColor = R.Color.orange500
            $0.onTintColor = R.Color.orange500
            $0.isOn = false
        }
        
        divider = divider.then {
            $0.backgroundColor = R.Color.gray200
        }
        
        eventSubLabel = eventSubLabel.then {
            $0.text = "MMM가 보내는 다양한 이벤트와 정보를 받는 알림으로 맞춤 정보 알림과는 무관해요"
            $0.numberOfLines = 0
            $0.font = R.Font.body3
            $0.textColor = R.Color.gray800
        }
        
        infoSubLabel = infoSubLabel.then {
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
        eventPushStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        eventSubLabel.snp.makeConstraints {
            $0.top.equalTo(eventPushStackView.snp.bottom).offset(13)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(eventSubLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(1)
        }
        
        infoPushStackView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        infoSubLabel.snp.makeConstraints {
            $0.top.equalTo(infoPushStackView.snp.bottom).offset(13)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        timeSettingLabel.snp.makeConstraints {
            $0.top.equalTo(infoSubLabel.snp.bottom).offset(24)
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
    func didAlertCacelButton() {
        print("확인 버튼")
    }
    
    func didAlertCofirmButton() {
        print("취소")
    }
}
