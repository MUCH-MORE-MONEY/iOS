//
//  EditActivityViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/22.
//

import UIKit
import Combine
import Then
import SnapKit
import Photos

protocol StarPickerViewProtocol: AnyObject {
    func willPickerDismiss(_ rate: Double)
}

final class EditActivityViewController: BaseAddActivityViewController, UINavigationControllerDelegate {
    // MARK: - UI Components
    private lazy var editIconImage = UIImageView()
    private lazy var titleStackView = UIStackView()
    private lazy var titleIcon = UIImageView()
    private lazy var titleText = UILabel()
    private lazy var deleteActivityButtonItem = UIBarButtonItem()
    private lazy var deleteButton = UIButton()
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    private var detailViewModel: HomeDetailViewModel
	private var editViewModel = EditActivityViewModel(isAddModel: false)
    private var date: Date
    private var navigationTitle: String {
        return date.getFormattedDate(format: "yyyy.MM.dd")
    }
    private let editAlertTitle = "편집을 그만두시겠어요?"
    private let editAlertContentText = "편집한 내용이 사라지니 유의해주세요!"
    
    private let deleteAlertTitle = "경제활동을 삭제하시겠어요?"
    private let deleteAlertContentText = "활동이 영구적으로 사라지니 유의해주세요!"
    private var keyboardHeight: CGFloat = 0
    private var isDeleteButton = false
    
    init(viewModel: HomeDetailViewModel, date: Date) {
        self.detailViewModel = viewModel
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didTapBackButton() {
        //FIXME: - showAlert에서 super.didTapBackButton()호출하면 문제생김
        isDeleteButton = false
        showAlert(alertType: .canCancel, titleText: editAlertTitle, contentText: editAlertContentText, cancelButtonText: "닫기", confirmButtonText: "그만두기")
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
    
}

extension EditActivityViewController {
    // MARK: - Style & Layout
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        navigationItem.rightBarButtonItem = deleteActivityButtonItem
        
        setCustomTitle()
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
        
        setUIByViewModel()
    }
    
    private func setLayout() {
        containerStackView.addArrangedSubview(editIconImage)
    }
    
    // MARK: - Bind
    private func bind() {
        // MARK: - detailVM -> editVM 데이터 주입
        editViewModel.title = detailViewModel.detailActivity?.title ?? ""
        editViewModel.memo = detailViewModel.detailActivity?.memo ?? ""
        editViewModel.amount = detailViewModel.detailActivity?.amount ?? 0
        editViewModel.createAt = detailViewModel.detailActivity?.createAt ?? ""
        editViewModel.star = detailViewModel.detailActivity?.star ?? 0
        editViewModel.type = detailViewModel.detailActivity?.type ?? ""
        editViewModel.fileNo = detailViewModel.detailActivity?.fileNo ?? ""
        editViewModel.id = detailViewModel.detailActivity?.id ?? ""
        
        // MARK: - UI Bind
        editViewModel.$star
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.satisfyingLabel.setSatisfyingLabelEdit(by: value)
                self.setStarImage(Int(value))
            }.store(in: &cancellable)
        
        editViewModel.$type
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.activityType.text = self.editViewModel.type == "01" ? "지출" : "수입"
                self.activityType.backgroundColor = self.editViewModel.type == "01" ? R.Color.orange500 : R.Color.blue500
            }.store(in: &cancellable)
        
        editViewModel.$amount
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.totalPrice.text = self.editViewModel.amount.withCommas() + "원"
            }.store(in: &cancellable)
        
        editViewModel.isTitleVaild
            .sinkOnMainThread(receiveValue: {
                if !$0 {
                    self.titleTextFeild.text?.removeLast()
                }
            }).store(in: &cancellable)
        
        titleTextFeild.textPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.title, on: editViewModel)
            .store(in: &cancellable)
        
        
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
                    self.textViewDidEndEditing()
                default:
                    print("unknown error")
                }
            }.store(in: &cancellable)
        
        cameraImageView.setData(viewModel: editViewModel)
        editViewModel.$didTapAddButton
            .sinkOnMainThread(receiveValue: { [weak self] in
                guard let self = self else { return }
                if $0 {
                    self.editViewModel.requestPHPhotoLibraryAuthorization {
                        DispatchQueue.main.async {
                            self.didTapAlbumButton()
                        }
                    }
                }
            })
            .store(in: &cancellable)
        
        // MARK: - Gesture Publisher
        titleStackView.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.didTapDateTitle()
            }.store(in: &cancellable)
        
        containerStackView.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.didTapMoneyLabel()
            }.store(in: &cancellable)
        
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
        
        
        // MARK: - CRUD Publisher
        saveButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapSaveButton)
            .store(in: &cancellable)
        
        deleteButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapDeleteButton)
            .store(in: &cancellable)
        
        // Date Picker의 값을 받아옴
        editViewModel.$date
            .sinkOnMainThread(receiveValue: { [weak self] date in
                guard let date = date else { return }
                self?.date = date
                self?.titleText.text = self?.navigationTitle
            }).store(in: &cancellable)
    }
}

// MARK: - Action
extension EditActivityViewController {
    func didTapDateTitle() {
        let picker = DatePickerViewController(viewModel: editViewModel, date: date)
        let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
        picker.delegate = bottomSheetVC
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.setSetting(height: 375)
        self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
    }
    
    func didTapMoneyLabel() {
        let picker = EditPriceViewController(editViewModel: editViewModel)
        let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
        picker.delegate = bottomSheetVC
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.setSetting(height: 230, isDrag: false)
        self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
    }
    
    func didTapStarLabel() {
        let picker = StarPickerViewController()
        let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
        picker.delegate = bottomSheetVC
        picker.starDelegate = self
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.setSetting(height: 288)
        self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
    }
    
    func didTapSaveButton() {
        detailViewModel.isShowToastMessage = true
        self.navigationController?.popViewController(animated: true)
        editViewModel.updateDetailActivity()
    }
    
    func didTapDeleteButton() {
        isDeleteButton = true
        showAlert(alertType: .canCancel, titleText: deleteAlertTitle, contentText: deleteAlertContentText, cancelButtonText: "닫기", confirmButtonText: "그만두기")
    }
    
    func didTapAlbumButton() {
        let picker = UIImagePickerController().then {
            $0.sourceType = .photoLibrary
            $0.allowsEditing = true
            $0.delegate = self
        }
    
        present(picker, animated: true)
    }
    
    func didTapImageView() {
        
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
            self.editViewModel.binaryFileList.removeAll()
            self.editViewModel.fileNo = ""
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
}


// MARK: - UI Funcitons
extension EditActivityViewController {
    private func setCustomTitle() {
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubviews(titleText, titleIcon)
        titleStackView = titleStackView.then {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.distribution = .fillProportionally
        }
        titleText = titleText.then {
            $0.text = navigationTitle
            $0.font = R.Font.title3
            $0.textColor = .white
        }
        
        titleIcon = titleIcon.then {
            $0.image = R.Icon.arrowExpandMore16
            $0.contentMode = .scaleAspectFit
        }
        
        navigationItem.titleView = titleStackView
    }
    
    private func setUIByViewModel() {
        
        satisfyingLabel.setSatisfyingLabelEdit(by: detailViewModel.detailActivity?.star ?? 0)
        
        memoTextView.text = detailViewModel.detailActivity?.memo
        titleTextFeild.text = detailViewModel.detailActivity?.title
        
        for i in 0..<(detailViewModel.detailActivity?.star ?? 0) {
            starList[i].image = R.Icon.iconStarBlack16
        }
        
        if let amount = detailViewModel.detailActivity?.amount {
            self.totalPrice.text = "\(amount.withCommas())원"
        }
        if let image = detailViewModel.mainImage {
            mainImageView.image = image
        }
        hasImage = detailViewModel.hasImage
        
        if hasImage {
            remakeConstraintsByMainImageView()
        } else {
            remakeConstraintsByCameraImageView()
        }
    }
    
    private func setStarImage(_ rate: Int) {
        self.editViewModel.star = rate
        for star in starList {
            star.image = R.Icon.iconStarGray16
        }
        for i in 0..<rate {
            self.starList[i].image = R.Icon.iconStarBlack16
        }
    }
}

extension EditActivityViewController: CustomAlertDelegate {
    func didAlertCofirmButton() {
        if isDeleteButton {
            editViewModel.deleteDetailActivity()
            if let navigationController = self.navigationController {
                if let rootViewController = navigationController.viewControllers.first {
                    navigationController.setViewControllers([rootViewController], animated: true)
                }
            }
        } else {
            super.didTapBackButton()
        }
    }
    
    func didAlertCacelButton() { }
}

// MARK: - Star Picker의 확인을 눌렀을 때
extension EditActivityViewController: StarPickerViewProtocol {
    func willPickerDismiss(_ rate: Double) {
        let rate = Int(rate)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setStarImage(rate)
        }
    }
}

// MARK: - ImagePicker Delegate
extension EditActivityViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            self.editViewModel.binaryFileList.removeAll()
            let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.mainImageView.image = img
            self.editViewModel.fileNo = ""
            guard let data = img?.jpegData(compressionQuality: 0)?.base64EncodedString() else { return }
            var imageName = ""
            if let imageUrl = info[UIImagePickerController.InfoKey.referenceURL] as? URL{
                let assets = PHAsset.fetchAssets(withALAssetURLs: [imageUrl], options: nil)
                guard let firstObject = assets.firstObject else { return }
                imageName = PHAssetResource.assetResources(for: firstObject).first?.originalFilename ?? "defaultName"
            }
            
            self.editViewModel.binaryFileList.append(APIParameters.BinaryFileList(binaryData: data,fileNm: imageName))
            self.remakeConstraintsByMainImageView()
        }
        print("이미지 변경")
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TextView Func
extension EditActivityViewController {
    func textViewDidChange(text: String) {
        editViewModel.memo = text
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
    
    func textViewDidEndEditing() {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if memoTextView.text.isEmpty {
            memoTextView.text = textViewPlaceholder
            memoTextView.textColor = R.Color.gray400
        }
    }
}
