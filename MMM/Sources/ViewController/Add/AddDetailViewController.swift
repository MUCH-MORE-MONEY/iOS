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
import Lottie

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
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				rootVC.navigationController?.setNavigationBarHidden(false, animated: false)    // navigation bar 노출
			}
		}
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracking.FinActAddPage.viewDetailLogEvent()
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
		viewModel.insertDetailActivity()
		
		self.loadView.play()
		self.loadView.isPresent = true
		self.loadView.modalPresentationStyle = .overFullScreen
		self.present(self.loadView, animated: false)
        
        Tracking.FinActAddPage.completeLogEvent()
	}
	
	func didTapAlbumButton() {
        Tracking.FinActAddPage.inputPhotoLogEvent()
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
        viewModel.memo = text
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

// MARK: - ImagePicker Delegate
extension AddDetailViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: false) { [weak self] in
			guard let self = self else { return }
            self.viewModel.binaryFileList.removeAll()
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
        self.viewModel.didTapAddButton = false
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.viewModel.didTapAddButton = false
		dismiss(animated: true, completion: nil)
	}
}

// MARK: - Style & Layout & Bind
extension AddDetailViewController {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    // MARK: - bind
    private func bind() {
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
        
        
        // MARK: - UI Bind
        viewModel.$type
            .receive(on: DispatchQueue.main)
            .sink {
                self.activityType.backgroundColor = $0 == "01" ? R.Color.orange500 : R.Color.blue500
            }.store(in: &cancellable)
        
        viewModel.$star
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
    }
    
    private func setAttribute() {
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
    
    private func setLayout() {
        remakeConstraintsByCameraImageView()
    }
}
