//
//  AddDetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/31.
//

import UIKit
import Combine
import SnapKit
import Then
import PhotosUI
import Lottie
import SwiftUI

final class AddDetailViewController: BaseAddActivityViewController, UINavigationControllerDelegate {
    // MARK: - UI Components
    // MARK: - Loading
    private lazy var loadView = LoadingViewController()
    // MARK: - Properties
    private var viewModel: EditActivityViewModel
    var keyboardHeight: CGFloat = 0
    private var cancellable = Set<AnyCancellable>()
    
    init(viewModel: EditActivityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        titleTextFeild.becomeFirstResponder() // 키보드 보이기 및 포커스 주기
        Tracking.FinActAddPage.viewDetailLogEvent()
    }
}
// MARK: - Action
extension AddDetailViewController {
    func didTapStarLabel() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
        let picker = StarPickerViewController()
        let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
        picker.delegate = bottomSheetVC
        picker.starDelegate = self
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.setSetting(height: 288)
        self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
    }
    
    func didTapSaveButton() {
        viewModel.insertDetailActivity()
        
        // 통계 Refresh
        if let str = Constants.getKeychainValue(forKey: Constants.KeychainKey.statisticsDate), let date = str.toDate() {
            ServiceProvider.shared.statisticsProvider.updateDate(to: date)
        } else {
            ServiceProvider.shared.statisticsProvider.updateDate(to: Date())
        }
        
        // Home Loading을 보여줄지 판단
        Constants.setKeychain(true, forKey: Constants.KeychainKey.isHomeLoading)
        
        self.loadView.play()
        self.loadView.isPresent = true
        self.loadView.modalPresentationStyle = .overFullScreen
        self.present(self.loadView, animated: false)
        
        // 최초 한번 true로 바꿔줌 - nudge 용 로직
        if !Common.getSaveButtonTapped() {
            Common.setSaveButtonTapped(true)
        }
        
        Tracking.FinActAddPage.completeLogEvent()
    }
    
    func didTapAlbumButton() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
        Tracking.FinActAddPage.inputPhotoLogEvent()

        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1 // 사용자가 한 번에 선택할 수 있는 사진의 수
        config.filter = .images // 사진만 선택
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func didTapImageView() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //앨범 선택 - 스타일(default)
        actionSheet.addAction(UIAlertAction(title: "앨범선택", style: .default, handler: { [weak self] (ACTION:UIAlertAction) in
            guard let self = self else { return }
            self.didTapAlbumButton()
            print("앨범선택")
        }))
        
        //사진삭제 - 스타일(destructive)
        actionSheet.addAction(UIAlertAction(title: "사진삭제", style: .destructive, handler: { [weak self] (ACTION:UIAlertAction) in
            guard let self = self else { return }
            self.mainImageView.image = nil
            self.viewModel.binaryFileList = []
            self.viewModel.fileNo = ""
            print("사진삭제")
            self.remakeConstraintsByCameraImageView()
        }))
        
        //취소 버튼 - 스타일(cancel)
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func limitTextLength(_ text: String, maxLength: Int) -> String {
        let length = text.count
        if length > maxLength {
            let endIndex = text.index(text.startIndex, offsetBy: maxLength)
            return String(text[..<endIndex])
        }
        return text
    }
    
    private func setStarImage(_ rate: Int) {
        for star in starList {
            star.image = R.Icon.iconStarGray16
        }
        for i in 0..<rate {
            self.starList[i].image = R.Icon.iconStarBlack16
        }
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
    
    // MARK: - TextView
    func textViewDidChange(text: String) {
        if self.memoTextView.text == textViewPlaceholder {
            self.memoTextView.text = nil
            self.memoTextView.textColor = R.Color.black
        }
    }
    
    func textViewDidBeginEditing() {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = scrollView.frame
        rect.size.height -= keyboardHeight
        if !rect.contains(memoTextView.frame.origin) {
            scrollView.scrollRectToVisible(memoTextView.frame, animated: true)
        }
        
        if memoTextView.text == textViewPlaceholder {
            memoTextView.text = nil
            memoTextView.textColor = R.Color.black
        }
    }
    
    func textViewDidEndEditing(text: String) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if memoTextView.text.isEmpty {
            memoTextView.text = textViewPlaceholder
            memoTextView.textColor = R.Color.gray400
        }
        
        viewModel.memo = text
    }
    
    private func didTapCategory() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
        let picker = AddCategoryViewController(viewModel: viewModel)
        let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
        bottomSheetVC.setSetting(percentHeight: 0.65)
        picker.delegate = bottomSheetVC
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        self.present(bottomSheetVC, animated: false, completion: nil)
    }
    
    private func didTapAddScheduleTapView(_ type: UIView.GestureType) {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
        
        let hostingController = UIHostingController(rootView: VStack {
            AddScheduleView(editViewModel: viewModel)
            Spacer()
        })
        
        if #available(iOS 16.0, *) {
            if let sheetController =  hostingController.sheetPresentationController {
                sheetController.detents = [
                        .custom { _ in
                            return UIScreen.height * 0.6
                        }
                    ]
                
                sheetController.prefersGrabberVisible = true
                self.present(hostingController, animated: true)
            }
        } else {
            let bottomSheetVC = BottomSheetViewController(contentViewController: hostingController)
            bottomSheetVC.setSetting(percentHeight: 542/812)

            bottomSheetVC.modalPresentationStyle = .overFullScreen
            self.present(bottomSheetVC, animated: false)
        }
        
        
//        let bottomSheetVC = BottomSheetViewController(contentViewController: vc)
//        bottomSheetVC.setSetting(percentHeight: 542/812)
        

    }
}

// MARK: - Star Picker의 확인을 눌렀을 때
extension AddDetailViewController: StarPickerViewProtocol {
    func willPickerDismiss(_ rate: Double) {
        let rate = Int(rate)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewModel.star = rate
            self.setStarImage(rate)
        }
        Tracking.FinActAddPage.nextBtnRatingLogEvent()
    }
}

// MARK: - PHPicker Delegate
extension AddDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.viewModel.binaryFileList.removeAll()
            
            let itemProvider = results.first?.itemProvider
            if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self.mainImageView.image = image
                            guard let data = image.jpegData(compressionQuality: 0)?.base64EncodedString() else { return }
                            
                            let identifier = results.compactMap(\.assetIdentifier)
                            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifier, options: nil)
                            let fileName = fetchResult.firstObject?.value(forKey: "filename") as? String ?? "defaultName"
                            
                            self.viewModel.binaryFileList.append(APIParameters.BinaryFileList(binaryData: data, fileNm: fileName))
                            self.remakeConstraintsByMainImageView()
                        }
                    }
                }
            }
            self.viewModel.didTapAddButton = false
        }
    }
}

// MARK: - Style & Layout & Bind
extension AddDetailViewController {
    // MARK: - bind
    override func setBind() {
        // MARK: - Loading
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink {
                if !$0 {
                    self.loadView.dismiss(animated: false)
                    if let navigationController = self.navigationController {
                        if let rootVC = navigationController.viewControllers.first {
                            navigationController.setViewControllers([rootVC], animated: true)
                        }
                    }
                } else {
                    
                }
            }.store(in: &cancellable)
        
        titleTextFeild.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.title, on: viewModel)
            .store(in: &cancellable)
        
        titleTextFeild.endEditPublisher
            .receive(on: DispatchQueue.global())
            .sink { _ in
                Tracking.FinActAddPage.inputTitleLogEvent()
            }.store(in: &cancellable)
        
        titleTextFeild.textReturnPublisher
            .sinkOnMainThread { [weak self] in
                guard let self = self else { return }
                self.titleTextFeild.resignFirstResponder()
            }
            .store(in: &cancellable)
        
        memoTextView.textPublisher
            .sink { [weak self] ouput in
                guard let self = self else { return }
                // 0 : textViewDidChange
                // 1 : textViewDidBeginEditing
                // 2 : textViewDidEndEditing
                switch ouput.1 {
                case 0:
                    self.textViewDidChange(text: ouput.0)
                case 1:
                    self.textViewDidBeginEditing()
                case 2:
                    self.textViewDidEndEditing(text: ouput.0)
                    Tracking.FinActAddPage.inputMemoLogEvent()
                default:
                    print("unknown error")
                }
            }.store(in: &cancellable)
        
        cameraImageView.setData(viewModel: viewModel)
        
        starStackView.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.didTapStarLabel()
            }.store(in: &cancellable)
        
        satisfyingLabel.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.didTapStarLabel()
            }.store(in: &cancellable)
        
        mainImageView.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.didTapImageView()
            }.store(in: &cancellable)
        
        addCategoryView.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.didTapCategory()
            }.store(in: &cancellable)
        
        addScheduleTapView.gesturePublisher()
            .sinkOnMainThread(receiveValue: didTapAddScheduleTapView)
            .store(in: &cancellable)
        
        // MARK: - UI Bind
        viewModel.$type
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {
                self.activityType.backgroundColor = $0 == "01" ? R.Color.orange500 : R.Color.blue500
                self.activityType.text = $0 == "01" ? "지출" : "수입"
            }.store(in: &cancellable)
        
        viewModel.$star
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.satisfyingLabel.setSatisfyingLabelEdit(by: value)
                self.setStarImage(Int(value))
            }.store(in: &cancellable)
        
        // textfield가 없을 때 버튼 비활성화
        titleTextFeild.textPublisher
            .sinkOnMainThread { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.saveButton.isEnabled = false
                    self.saveButton.setBackgroundColor(R.Color.gray400, for: .disabled)
                } else {
                    self.saveButton.isEnabled = true
                    self.saveButton.setBackgroundColor(R.Color.gray800, for: .normal)
                }
            }.store(in: &cancellable)
        // 제목 글자수 16자 제한
        viewModel.isTitleVaild
            .sinkOnMainThread(receiveValue: {
                if !$0 {
                    self.titleTextFeild.text?.removeLast()
                }
            }).store(in: &cancellable)
        
        viewModel.$memo
            .sinkOnMainThread { [weak self] text in
                guard let self = self else { return }
                if !text.isEmpty {
                    self.memoTextView.textColor = R.Color.black
                } else {
                    self.memoTextView.text = textViewPlaceholder
                    self.memoTextView.textColor = R.Color.gray400
                }
            }.store(in: &cancellable)
        
        // MARK: - CRUD Publisher
        saveButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapSaveButton)
            .store(in: &cancellable)
        
        cameraImageView.setData(viewModel: viewModel)
        viewModel.$didTapAddButton
            .sinkOnMainThread(receiveValue: { [weak self] in
                guard let self = self else { return }
                print($0)
                if $0 {
                    self.viewModel.requestPHPhotoLibraryAuthorization {
                        DispatchQueue.main.async {
                            self.didTapAlbumButton()
                        }
                    }
                }
            }).store(in: &cancellable)
        
        // 카테고리 이름 변경
        viewModel.$categoryName
            .sinkOnMainThread { [weak self] name in
                guard let self = self else { return }
                self.addCategoryView.setTitleAndColor(by: name)
            }
            .store(in: &cancellable)
        
        viewModel.$isCategoryManageButtonTapped
            .sinkOnMainThread { [weak self] isTapped in
                guard let self = self else { return }
                print(isTapped)
                if isTapped {
                    let mode: CategoryEditViewController.Mode = self.viewModel.type == "01" ? .pay : .earn
                    
                    let vc = CategoryEditViewController(mode: mode)
                    vc.reactor = CategoryEditReactor(provider: ServiceProvider.shared, type: self.viewModel.type)

                    // FIXME: - 의존성 주입 바꿔야함
                    vc.editViewModel = self.viewModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .store(in: &cancellable)
        
        viewModel.$isViewFromCategoryViewController
            .sinkOnMainThread { [weak self] isFromView in
                guard let self = self else { return }
                if isFromView {
                    view.endEditing(true)
                    self.didTapCategory()
                }
            }
            .store(in: &cancellable)
        
        viewModel.$type
            .removeDuplicates() // 값 변경전까지 이벤트 미방출
            .sinkOnMainThread { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.categoryId = ""
                self.viewModel.categoryName = ""
            }
            .store(in: &cancellable)
        
        viewModel.$recurrenceTitle
            .sinkOnMainThread { [weak self] text in
                guard let self = self else { return }
                self.addScheduleTapView.setTitleAndColor(by: text)
            }
            .store(in: &cancellable)
    }
    
    override func setAttribute() {
        super.setAttribute()
        
        titleTextFeild.becomeFirstResponder() // 키보드 보이기 및 포커스 주기
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
        title = viewModel.date?.getFormattedDate(format: "MM월 dd일 경제활동")
        
        totalPrice = totalPrice.then {
            $0.text = viewModel.amount.withCommas() + "원"
        }
        
        saveButton = saveButton.then {
            $0.isEnabled = false
            $0.setBackgroundColor(R.Color.gray400, for: .disabled)
        }
    }
    
    override func setLayout() {
        super.setLayout()
        remakeConstraintsByCameraImageView()
    }
}
