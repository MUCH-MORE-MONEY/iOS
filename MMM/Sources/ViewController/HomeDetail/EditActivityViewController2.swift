//
//  EditActivityViewController2.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/9/24.
//

import UIKit
import Then
import SnapKit
import Photos
import Lottie
import FirebaseAnalytics
import RxSwift
import RxCocoa
import ReactorKit

final class EditActivityViewController2: BaseAddActivityViewController, View {
    typealias Reactor = EditActivityReactor
    
    // MARK: - UI Components
    private lazy var editIconImage = UIImageView()
    private lazy var titleStackView = UIStackView()
    private lazy var titleIcon = UIImageView()
    private lazy var titleText = UILabel()
    private lazy var deleteActivityButtonItem = UIBarButtonItem()
    private lazy var deleteButton = UIButton()
    
    // MARK: - Properties
//    private var date: Date
//    private var navigationTitle: String {
//        return date.getFormattedDate(format: "yyyy.MM.dd")
//    }
    private let editAlertTitle = "편집을 그만두시겠어요?"
    private let editAlertContentText = "편집한 내용이 사라지니 유의해주세요!"
    
    private let deleteAlertTitle = "경제활동을 삭제하시겠어요?"
    private let deleteAlertContentText = "활동이 영구적으로 사라지니 유의해주세요!"
    private var keyboardHeight: CGFloat = 0
    private var isDeleteButton = false

    // MARK: - Loading
    private lazy var loadView = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func didTapBackButton() {
        super.didTapBackButton()
        isDeleteButton = false
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            var rect = scrollView.frame
            rect.size.height -= keyboardHeight
            if !rect.contains(scrollView.frame.origin) {
                scrollView.scrollRectToVisible(scrollView.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
    }
    
    func bind(reactor: EditActivityReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension EditActivityViewController2 {
    private func bindAction(_ reactor: EditActivityReactor) {
        reactor.action.onNext(.loadData)
    }
    
    private func bindState(_ reactor: EditActivityReactor) {
        reactor.state
            .compactMap { $0.activity?.star}
            .bind(onNext: setStar)
            .disposed(by: disposeBag)
        
        reactor.state
            .observe(on: MainScheduler.instance)
            .compactMap { $0.activity?.amount}
            .bind(onNext: setPrice)
            .disposed(by: disposeBag)
        
        reactor.state
            .observe(on: MainScheduler.instance)
            .compactMap { $0.activity?.type }
            .bind(onNext: setType)
            .disposed(by: disposeBag)
        
        reactor.state
            .observe(on: MainScheduler.instance)
            .compactMap { $0.activity?.memo }
            .bind(onNext: setMemo)
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions
extension EditActivityViewController2 {
    private func setStar(_ count: Int?) {
        guard let count = count else { return }
        satisfyingLabel.setSatisfyingLabel(by: count)
        
        for i in 0..<count {
            starList[i].image = R.Icon.iconStarBlack16
        }
        
        for star in starList {
            star.image = R.Icon.iconStarGray16
        }
        
        for i in 0..<count {
            self.starList[i].image = R.Icon.iconStarBlack16
        }
    }
    
    private func setPrice(_ price: Int?) {
        guard let price = price else { return }
        print("EditVC : \(price)")
        self.totalPrice.text = price.withCommas() + "원"
    }
    
    private func setType(_ type: String?) {
        guard let type = type else { return }
        activityType.text = type == "01" ? "지출" : "수입"
        activityType.backgroundColor = type == "01" ? R.Color.orange500 : R.Color.blue500
    }
    
    private func setMemo(_ memo: String?) {
        guard let memo = memo else { return }
        if memo.isEmpty {
            memoTextView.text = textViewPlaceholder
            memoTextView.textColor = R.Color.gray400
        } else {
            memoTextView.textColor = R.Color.black
        }
    }
}

//MARK: - Attribute & Hierarchy & Layouts
extension EditActivityViewController2 {
    override func setAttribute() {
        super.setAttribute()
        self.hideKeyboardWhenTappedAround()
        titleTextFeild.becomeFirstResponder() // 키보드 보이기 및 포커스 주기
        
        
        
        
        navigationItem.titleView = titleStackView
        navigationItem.rightBarButtonItem = deleteActivityButtonItem
        
        titleStackView = titleStackView.then {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.distribution = .fillProportionally
        }
        titleText = titleText.then {
            $0.text = "navigationTitle"
            $0.font = R.Font.title3
            $0.textColor = .white
        }
        
        titleIcon = titleIcon.then {
            $0.image = R.Icon.arrowExpandMore16
            $0.contentMode = .scaleAspectFit
        }
        
        deleteActivityButtonItem = deleteActivityButtonItem.then {
            $0.customView = deleteButton
        }
        
        deleteButton = deleteButton.then {
            $0.setTitle("삭제", for: .normal)
        }
                
        editIconImage = editIconImage.then {
            $0.image = R.Icon.iconEditGray24
            $0.contentMode = .scaleAspectFit
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        view.addSubviews(titleStackView)
        titleStackView.addArrangedSubviews(titleText, titleIcon)
        containerStackView.addArrangedSubview(editIconImage)
    }
    
    override func setLayout() {
        super.setLayout()
    }
}
