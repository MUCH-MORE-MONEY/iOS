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
import Photos

class AddDetailViewController: BaseAddActivityViewController {
    // MARK: - UI Components
    
    // MARK: - Properties
    private var viewModel: EditActivityViewModel

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
        setup()
    }
}

// MARK: - Style & Layout & Bind
extension AddDetailViewController {
    private func setup() {
        setAttribute()
        setLayout()
        bind()
        self.hideKeyboardWhenTappedAround()
    }
    
    private func setAttribute() {
        title = viewModel.date?.getFormattedDate(format: "MM월 dd일 경제활동")
        totalPrice.text = viewModel.amount.withCommas() + "원"
    }
    
    private func setLayout() {
        remakeConstraintsByCameraImageView()
        if viewModel.star == 0 { }
    }
    
    // MARK: - bind
    private func bind() {
        titleTextFeild.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.title, on: viewModel)
            .store(in: &cancellable)
        
        memoTextView.textPublisher
            .sink { text in
                self.viewModel.memo = text
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
        
        
        // MARK: - UI Bind
        viewModel.$star
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.satisfyingLabel.setSatisfyingLabelEdit(by: value)
                self.setStarImage(Int(value))
            }.store(in: &cancellable)
        
        // MARK: - CRUD Publisher
        saveButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapSaveButton)
            .store(in: &cancellable)
        
        cameraImageView.setData(viewModel: viewModel)
        viewModel.$didTapAddButton
            .sinkOnMainThread(receiveValue: { [weak self] in
                guard let self = self else { return }
                if $0 {
                    self.viewModel.requestPHPhotoLibraryAuthorization {
                        DispatchQueue.main.async {
                            self.didTapAlbumButton()
                        }
                    }
                }
            }).store(in: &cancellable)
    }
}

// MARK: - Action
extension AddDetailViewController {
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
        //        viewModel.isShowToastMessage = true
        self.navigationController?.popViewController(animated: true)
        viewModel.insertDetailActivity()
        
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
}

// MARK: - Star Picker의 확인을 눌렀을 때
extension AddDetailViewController: StarPickerViewProtocol {
    func willPickerDismiss(_ rate: Double) {
        let rate = Int(rate)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setStarImage(rate)
        }
    }
}

extension AddDetailViewController: UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            self.viewModel.binaryFileList = []
            let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.mainImageView.image = img
            
            guard let data = img?.jpegData(compressionQuality: 1)?.base64EncodedString() else { return }
            var imageName = ""
            if let imageUrl = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                let assets = PHAsset.fetchAssets(withALAssetURLs: [imageUrl], options: nil)
                
                guard let firstObject = assets.firstObject else { return }
                imageName = PHAssetResource.assetResources(for: firstObject).first?.originalFilename ?? "DefualtName"
            }
            
            self.viewModel.binaryFileList.append(APIParameters.BinaryFileList(binaryData: data, fileNm: imageName))
            self.remakeConstraintsByMainImageView()
        }
        print("이미지 변경")
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UI Action
extension AddDetailViewController {
    private func setStarImage(_ rate: Int) {
        self.viewModel.star = rate
        for star in starList {
            star.image = R.Icon.iconStarGray16
        }
        for i in 0..<rate {
            self.starList[i].image = R.Icon.iconStarBlack16
        }
    }
}
