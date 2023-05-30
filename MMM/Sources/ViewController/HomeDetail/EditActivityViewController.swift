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
    private var editViewModel = EditActivityViewModel()
    private var date: Date
    private var navigationTitle: String {
        return date.getFormattedDate(format: "yyyy.MM.dd")
    }
    private let editAlertTitle = "편집을 그만두시겠어요?"
    private let editAlertContentText = "편집한 내용이 사라지니 유의해주세요!"
    
    private let deleteAlertTitle = "경제활동을 삭제하시겠어요?"
    private let deleteAlertContentText = "활동이 영구적으로 사라지니 유의해주세요!"
    
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
    }
    
    override func didTapBackButton() {
        super.didTapBackButton()
        //FIXME: - showAlert에서 super.didTapBackButton()호출하면 문제생김
//        showAlert(alertType: .canCancel, titleText: alertTitle, contentText: alertContentText, cancelButtonText: "닫기", confirmButtonText: "그만두기")
    }
}

extension EditActivityViewController {
    // MARK: - Style & Layout
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
        
    private func setAttribute() {
        navigationItem.rightBarButtonItem = deleteActivityButtonItem
        
        setCustomTitle()
        deleteActivityButtonItem = deleteActivityButtonItem.then {
            $0.customView = deleteButton
        }
        
        deleteButton = deleteButton.then {
            $0.setTitle("삭제", for: .normal)
        }
        
        containerStackView.addArrangedSubview(editIconImage)
        
        editIconImage = editIconImage.then {
            $0.image = R.Icon.iconEditGray24
            $0.contentMode = .scaleAspectFit
        }
        

        
        setUIByViewModel()

    }
    
    private func setLayout() {  }
    
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
        
        print(detailViewModel.detailActivity)
        
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
		
        editViewModel.isVaild
            .sinkOnMainThread(receiveValue: {
                if !$0 {
                    self.titleTextFeild.text?.removeLast()
                }
            }).store(in: &cancellable)
        
        titleTextFeild.textPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.title, on: editViewModel)
            .store(in: &cancellable)
        
        memoTextView.textPublisher
            .sink(receiveValue: { text in
                self.editViewModel.memo = text
            })
            .store(in: &cancellable)
        
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
		bottomSheetVC.setSetting(height: 210, isDrag: false)
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
//        print(editViewModel.binaryFileList)
        print(editViewModel.amount)
        print(editViewModel.type)
        print(editViewModel.title)
        print(editViewModel.memo)
        print(editViewModel.id)
        print(editViewModel.createAt)
        print(editViewModel.fileNo)
        print(editViewModel.star)
        editViewModel.updateDetailActivity()
    }
    
    func didTapDeleteButton() {
        //FIXME: - showAlert에서 super.didTapBackButton()호출하면 문제생김
//        showAlert(alertType: .canCancel, titleText: deleteAlertTitle, contentText: deleteAlertContentText, cancelButtonText: "닫기", confirmButtonText: "그만두기")
        self.navigationController?.popViewController(animated: true)
        
        editViewModel.deleteDetailActivity()
    }
    
    func didTapAlbumButton() {
        let picker = UIImagePickerController()
        
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        picker.delegate = self
        
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
			self.editViewModel.binaryFileList = []
			self.editViewModel.fileNo = ""
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
        super.didTapBackButton()
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

extension EditActivityViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
			self.editViewModel.binaryFileList = []
            let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.mainImageView.image = img
            self.editViewModel.fileNo = ""
            guard let data = img?.jpegData(compressionQuality: 1.0) else { return }
            self.editViewModel.binaryFileList.append(APIParameters.UpdateReqDto.BinaryFileList(binaryData: String(decoding: data, as: UTF8.self), fileNm: "\(img?.pngData()).jpeg"))
            print(self.editViewModel.binaryFileList.count)
            self.remakeConstraintsByMainImageView()
        }
        print("이미지 변경")
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("이미지를 선택하지 않고 취소")
    }
}
