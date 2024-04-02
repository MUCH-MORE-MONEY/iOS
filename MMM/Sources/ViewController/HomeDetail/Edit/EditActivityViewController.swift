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
import Lottie
import FirebaseAnalytics
import SwiftUI

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
    private var editViewModel: EditActivityViewModel
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
	
	// MARK: - Loading
	private lazy var loadView = LoadingViewController()

    init(detailViewModel: HomeDetailViewModel, editViewModel: EditActivityViewModel, date: Date) {
		self.detailViewModel = detailViewModel
        self.editViewModel = editViewModel
		self.date = date
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
    }
    
	override func didTapBackButton() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
		//FIXME: - showAlert에서 super.didTapBackButton()호출하면 문제생김
		isDeleteButton = false
		showAlert(alertType: .canCancel, titleText: editAlertTitle, contentText: editAlertContentText, cancelButtonText: "닫기", confirmButtonText: "편집 취소하기")
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

// MARK: - Action
extension EditActivityViewController {
	func didTapDateTitle() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
		let picker = DatePickerViewController(viewModel: editViewModel, date: date)
		let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
		picker.delegate = bottomSheetVC
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 375)
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
	
	func didTapMoneyLabel() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
		let picker = EditPriceViewController(editViewModel: editViewModel)
		let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
		picker.delegate = bottomSheetVC
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 230, isDrag: false)
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
	
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
        guard let detailActvity = detailViewModel.detailActivity else { return }
        
        let saveType = editViewModel.checkSaveType(by: detailActvity)
        
        let actionSheet = UIAlertController(title: "이 경제활동은 반복 설정되어있어요.", message: "편집 사항을 다른 일정에도 적용하시겠습니까?", preferredStyle: .actionSheet)
        

        
        // 반복된 경제활동일 경우에만 해당
        switch saveType {
        case .content:          // case 1 : 제목, 금액 ,별점, 카테고리, 사진, 내용 수정
            //앨범 선택 - 스타일(default)
            actionSheet.addAction(UIAlertAction(title: "이 경젷", style: .default, handler: { [weak self] (ACTION:UIAlertAction) in
                guard let self = self else { return }
                self.didTapAlbumButton()
                print("앨범선택")
            }))
            break
        case .date:             // case 2 : 날짜 수정
            break
        case .contentAndDate:   // case 3 : case 1 && case 2 수정
            break
        case .deleteRecurrence: // case 4 : 반복 없애기
            break
        case .noRecurrence:     // 원본 경제활동이 반복이 아닐경우
            break
        }

        
        editActivity()
	}
	
    func editActivity() {
        editViewModel.updateDetailActivity {
            self.detailViewModel.changedId = self.editViewModel.changedId
        }
        
        // 저장후, 통계 Refresh
        if let str = Constants.getKeychainValue(forKey: Constants.KeychainKey.statisticsDate), let date = str.toDate() {
            ServiceProvider.shared.statisticsProvider.updateDate(to: date)
        } else {
            ServiceProvider.shared.statisticsProvider.updateDate(to: Date())
        }
        
        self.loadView.play()
        self.loadView.isPresent = true
        self.loadView.modalPresentationStyle = .overFullScreen
        self.present(self.loadView, animated: false)
    }
    
	func didTapDeleteButton() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
		isDeleteButton = true
		showAlert(alertType: .canCancel, titleText: deleteAlertTitle, contentText: deleteAlertContentText, cancelButtonText: "닫기", confirmButtonText: "삭제하기")
	}
	
	func didTapAlbumButton() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
		let picker = UIImagePickerController().then {
			$0.sourceType = .photoLibrary
			$0.allowsEditing = true
			$0.delegate = self
		}
	
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
    
    private func didTapCategory() {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
        Tracking.FinActAddPage.inputCategoryLogEvent()
        
        let picker = AddCategoryViewController(viewModel: editViewModel)
        let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
        bottomSheetVC.setSetting(percentHeight: 0.65)
        picker.delegate = bottomSheetVC
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        self.present(bottomSheetVC, animated: false, completion: nil)
    }
    
    private func didTapAddScheduleTapView(_ type: UIView.GestureType) {
        // 키보드 내리기
        self.titleTextFeild.resignFirstResponder()
        
        let swiftUIView = VStack {
            AddScheduleView(editViewModel: editViewModel)
            Spacer()
        }
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
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
            
            if detailViewModel.detailActivity?.recurrenceYN == "Y" {
                let recurrenceDeleteTitle = "이 경제활동은 반복 설정되어있어요."
                let recurrenceDeleteMessage = "편집 사항을 다른 일정에도 적용하시겠습니까?"
                
                let alert = UIAlertController(title: recurrenceDeleteTitle, message: recurrenceDeleteMessage, preferredStyle: .actionSheet)
                let delRecurrenceNAction = UIAlertAction(title: "이 경제활동에만 적용", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    // 삭제시, 통계 Refresh
                    editViewModel.deleteDetailActivity(delRecurrenceYn: "N")
                    self.refreshStatistics()
                }
                
                let delRecurrenceYAction = UIAlertAction(title: "이후 경제활동에도 적용", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    // 삭제시, 통계 Refresh
                    editViewModel.deleteDetailActivity(delRecurrenceYn: "Y")
                    self.refreshStatistics()
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(delRecurrenceNAction)
                alert.addAction(delRecurrenceYAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            } else {
                editViewModel.deleteDetailActivity(delRecurrenceYn: "N")
                self.refreshStatistics()
            }
			


		} else {
			super.didTapBackButton()
		}
	}
	
	func didAlertCacelButton() { }
    
    private func refreshStatistics() {
        // 삭제시, 통계 Refresh
        if let str = Constants.getKeychainValue(forKey: Constants.KeychainKey.statisticsDate), let date = str.toDate() {
            ServiceProvider.shared.statisticsProvider.updateDate(to: date)
        } else {
            ServiceProvider.shared.statisticsProvider.updateDate(to: Date())
        }
        
        self.loadView.play()
        self.loadView.isPresent = true
        self.loadView.modalPresentationStyle = .overFullScreen
        self.present(self.loadView, animated: false)
    }
}

// MARK: - Star Picker의 확인을 눌렀을 때
extension EditActivityViewController: StarPickerViewProtocol {
	func willPickerDismiss(_ rate: Double) {
		let rate = Int(rate)
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.setStarImage(rate)
            self.editViewModel.star = rate
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
                
            // 이미지가 바뀌면
            self.editViewModel.isImageChanged = true

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
        self.editViewModel.didTapAddButton = false
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.editViewModel.didTapAddButton = false
		dismiss(animated: true, completion: nil)
	}
}

// MARK: - TextView Func
extension EditActivityViewController {
	func textViewDidChange(text: String) {
        if self.memoTextView.text == textViewPlaceholder {
            self.memoTextView.text = nil
            self.memoTextView.textColor = R.Color.black
        }
	}
	
	func textViewDidBeginEditing() {
//		let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
//		scrollView.contentInset = contentInsets
//		scrollView.scrollIndicatorInsets = contentInsets
//		
//		var rect = scrollView.frame
//		rect.size.height -= keyboardHeight
//		if !rect.contains(memoTextView.frame.origin) {
//			scrollView.scrollRectToVisible(memoTextView.frame, animated: true)
//		}
		
        
        
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
        
        editViewModel.memo = text
	}
}
// MARK: - Bind
extension EditActivityViewController {
	override func setBind() {
		// MARK: - detailVM -> editVM 데이터 주입
        
        guard let detailActivity = detailViewModel.detailActivity else { return }
		editViewModel.title = detailActivity.title
        editViewModel.memo = detailActivity.memo
		editViewModel.amount = detailActivity.amount
		editViewModel.createAt = detailActivity.createAt
		editViewModel.star = detailActivity.star
		editViewModel.type = detailActivity.type
		editViewModel.fileNo = detailActivity.fileNo
		editViewModel.id = detailActivity.id
        editViewModel.categoryId = detailActivity.categoryID
        editViewModel.categoryName = detailActivity.categoryName
        editViewModel.recurrenceInfo = detailActivity.recurrenceInfo
		// MARK: - Loading에 대한 처리
		editViewModel.$isLoading
            .removeDuplicates()
			.receive(on: DispatchQueue.main)
			.sink {
				if !$0 {
					self.loadView.dismiss(animated: false)
					
					if self.isDeleteButton {
						if let navigationController = self.navigationController {
							if let rootVC = navigationController.viewControllers.first {
								navigationController.setViewControllers([rootVC], animated: true)
							}
						}
					} else {
						super.didTapBackButton()
					}
				} else {
					
				}
			}.store(in: &cancellable)
		
		
		// MARK: - UI Bind
		editViewModel.$star
            .removeDuplicates()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] value in
				guard let self = self else { return }
				self.satisfyingLabel.setSatisfyingLabelEdit(by: value)
				self.setStarImage(Int(value))
			}.store(in: &cancellable)
		
		editViewModel.$type
            .removeDuplicates()
			.receive(on: DispatchQueue.main)
			.sink { _ in
				self.activityType.text = self.editViewModel.type == "01" ? "지출" : "수입"
				self.activityType.backgroundColor = self.editViewModel.type == "01" ? R.Color.orange500 : R.Color.blue500
			}
            .store(in: &cancellable)
		
        editViewModel.$type
            .removeDuplicates() // 값 변경전까지 이벤트 미방출
            .dropFirst()        // 최초 값이 변경되었을 때 무시
            .sinkOnMainThread { [weak self] _ in
                guard let self = self else { return }
                print("drop")
                self.editViewModel.categoryId = ""
                self.editViewModel.categoryName = ""
            }
            .store(in: &cancellable)

        
		editViewModel.$amount
            .removeDuplicates()
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
		
		editViewModel.$memo
			.sinkOnMainThread { [weak self] text in
				guard let self = self else { return }
				if !text.isEmpty {
					self.memoTextView.textColor = R.Color.black
				} else {
					self.memoTextView.text = textViewPlaceholder
					self.memoTextView.textColor = R.Color.gray400
				}
			}.store(in: &cancellable)
		
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
		
        // 키보드의 확인/이동 버튼을 눌렀을 경우 키보드 내리기
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
		
        
        addCategoryView.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.didTapCategory()
            }.store(in: &cancellable)
		
        addScheduleTapView.gesturePublisher()
            .sinkOnMainThread(receiveValue: didTapAddScheduleTapView)
            .store(in: &cancellable)
        
		// MARK: - CRUD Publisher
		saveButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapSaveButton)
			.store(in: &cancellable)
		
		deleteButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapDeleteButton)
			.store(in: &cancellable)
		
		// Date Picker의 값을 받아옴
		editViewModel.$date
            .removeDuplicates()
			.sinkOnMainThread(receiveValue: { [weak self] date in
				guard let self = self else { return }
				guard let date = date else { return }
				// 날짜 변경 감지 및 변경된 날짜 캡처
				self.detailViewModel.isDateChanged = true
				self.detailViewModel.changedDate = date
				self.date = date
				self.titleText.text = self.navigationTitle
				self.editViewModel.createAt = date.getFormattedDate(format: "yyyyMMdd")
			}).store(in: &cancellable)
        
        // 최초 진입했을 경우 카테고리 이름 변경
        editViewModel.$categoryName
            .removeDuplicates()
            .sinkOnMainThread { [weak self] name in
                guard let self = self else { return }
                self.addCategoryView.setTitleAndColor(by: name)
            }
            .store(in: &cancellable)
        
        
        editViewModel.$isCategoryManageButtonTapped
            .sinkOnMainThread { [weak self] isTapped in
                guard let self = self else { return }
                if isTapped {
                    let mode: CategoryEditViewController.Mode = self.editViewModel.type == "01" ? .pay : .earn
                    
                    let vc = CategoryEditViewController(mode: mode)
                    vc.reactor = CategoryEditReactor(provider: ServiceProvider.shared, type: self.editViewModel.type)

                    // FIXME: - 의존성 주입 바꿔야함
                    vc.editViewModel = self.editViewModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .store(in: &cancellable)
        
        editViewModel.$isViewFromCategoryViewController
            .sinkOnMainThread { [weak self] isFromView in
                guard let self = self else { return }
                if isFromView {
                    view.endEditing(true)
                    self.didTapCategory()
                }
            }
            .store(in: &cancellable)
        
        editViewModel.$recurrenceInfo
            .sinkCompactMapOnMainThread(receiveValue: addScheduleTapView.setTitle(by:))
            .store(in: &cancellable)
            
	}

}
//MARK: - Attribute & Hierarchy & Layouts
extension EditActivityViewController {
    override func setAttribute() {
		super.setAttribute()
        self.hideKeyboardWhenTappedAround()
        titleTextFeild.becomeFirstResponder() // 키보드 보이기 및 포커스 주기

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
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
    
	override func setHierarchy() {
		super.setHierarchy()
        containerStackView.addArrangedSubview(editIconImage)
    }
}
