//
//  EditActivityViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/23.
//

import UIKit
import Photos
import Combine
import FirebaseAnalytics

final class EditActivityViewModel: ObservableObject {
    // MARK: - Property Wrapper
    @Published var didTapAddButton: Bool = false
    @Published var isTitleEmpty = false
    @Published var priceInput: String = ""

    // MARK: - API Request를 위한 Property Wrapper
    @Published var title = ""
    @Published var memo = ""
    @Published var id = ""
    @Published var amount = 0
    @Published var createAt = ""
    @Published var star = 0
    @Published var type = "01"
    @Published var fileNo = ""
    @Published var binaryFileList: [APIParameters.BinaryFileList] = []
  	@Published var date: Date? // picker
    // UI용 카테고리
    @Published var categoryName = ""
    // api 통신용
    @Published var categoryId = ""

    
    // 카테고리 시트 뷰에서 관리 버튼을 눌렀을 때를 나타내는 flag
    @Published var isCategoryManageButtonTapped = false
    @Published var isViewFromCategoryViewController = false
    
    // 경제활동 반복
    @Published var recurrenceInfo: APIParameters.RecurrenceInfo?
    @Published var recurrenceTitle: String = "반복 안함"
    private var recurrenceYN: String {
        guard let info = recurrenceInfo else { return "N" }
        return info.recurrencePattern == "none" ? "N" : "Y"
    }
    @Published var contentRecurrenceUpdateYN: String = ""   // 반복된 경제활동 일 경우 : 이후 경제활동도 내용 변경 여부 Y/N
    @Published var recurrenceUpdateYN: String = ""          // 경제활동 패턴 변경 여부 Y/N
    
    @Published var editResponse: UpdateResDto?
    @Published var deleteResponse: DeleteResDto?
    @Published var insertResponse: InsertResDto?
    
    // MARK: - Loading
    @Published var isLoading = true
    @Published var isShowToastMessage = false
    // MARK: - Porperties
    private var cancellable: Set<AnyCancellable> = []
	var isAddModel: Bool
    lazy var isTitleVaild: AnyPublisher<Bool, Never> = $title
        .map { $0.count <= 16 } // 16자리 이하
        .eraseToAnyPublisher()
    
    // 날짜가 변경된 데이터의 id
    var changedId = ""
    
    // MARK: - Public properties
    // 들어온 퍼블리셔의 값 일치 여부를 반환하는 퍼블리셔
    lazy var isPriceVaild: AnyPublisher<Bool, Never> = $priceInput
        .map {0 <= Int($0) ?? 0 && Int($0) ?? 0 <= 10_000 } // 1억(1,000만원)보다 작을 경우
        .eraseToAnyPublisher()
    
    lazy var isValidByWon: AnyPublisher<Bool, Never> = $priceInput
        .map { 0 <= Int($0) ?? 0 && Int($0) ?? 0 <= 100_000_000 } // 1억(1,000만원)보다 작을 경우
        .eraseToAnyPublisher()
	
	init(isAddModel: Bool) {
		self.isAddModel = isAddModel
	}
    
    func requestPHPhotoLibraryAuthorization(completion: @escaping () -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorizationStatus in
                switch authorizationStatus {
                case .limited:
                    completion()
                    print("limited authorization granted")
                case .authorized:
                    completion()
                    print("authorization granted")
                default:
                    print("Unimplemented")
                }
            }
		}
    }
    
    func insertDetailActivity() {
        guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        self.isLoading = true
        APIClient.dispatch(
            APIRouter.InsertReqDto(
                headers: APIHeader.Default(token: token),
                body: APIParameters.InsertEconomicActivityReqDto(
                    binaryFileList: binaryFileList,
                    amount: amount,
                    category: categoryId,
                    type: type,
                    title: title,
                    memo: memo,
                    createAt: createAt,
                    star: star,
                    recurrenceInfo: recurrenceInfo,
                    recurrenceYN: recurrenceYN)))
        .sink { data in
            switch data {
            case .failure(_):
                break
            case .finished:
                break
            }
            self.isLoading = false
        } receiveValue: { response in
            self.insertResponse = response
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.showToast(message: "작성한 경제활동을 저장했습니다.")
            }
        }.store(in: &cancellable)
    }
    
    
    //    경제활동 수정 API
    //    파일유지->fileNo req body에 유지,
    //    파일 삭제-> fileNo=''
    //    파일 변경 -> fileNo='' and BinaryFileList 추가
    func updateDetailActivity() {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        self.isLoading = true
        self.isShowToastMessage = false
        APIClient.dispatch(
            APIRouter.UpdateReqDto(
                headers: APIHeader.Default(token: token),
                body: APIParameters.UpdateReqDto(
                    binaryFileList: binaryFileList,
                    amount: amount,
                    category: categoryId,
                    type: type,
                    title: title,
                    memo: memo,
                    id: id,
                    createAt: createAt,
                    fileNo: fileNo,
                    star: star,
                    contentRecurrenceUpdateYN: "N",
                    recurrenceUpdateYN: "N",
                    recurrenceInfo: recurrenceInfo,
                    recurrenceYN: "N")))
        .sink { data in
            switch data {
            case .failure(let error):
                print(error)
                break
            case .finished:
                break
            }
            self.isLoading = false
        } receiveValue: { response in
            self.editResponse = response
            self.isShowToastMessage = true
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.showToast(message: "경제활동 편집 내용을 저장했습니다.")
            }
        }.store(in: &cancellable)
    }
    
    func updateDetailActivity(completion: @escaping () -> Void) {
        guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        self.isLoading = true
        self.isShowToastMessage = false
        APIClient.dispatch(
            APIRouter.UpdateReqDto(
                headers: APIHeader.Default(token: token),
                body: APIParameters.UpdateReqDto(
                    binaryFileList: binaryFileList,
                    amount: amount,
                    category: categoryId,
                    type: type,
                    title: title,
                    memo: memo,
                    id: id,
                    createAt: createAt,
                    fileNo: fileNo,
                    star: star,
                    contentRecurrenceUpdateYN: "N",
                    recurrenceUpdateYN: "N",
                    recurrenceInfo: recurrenceInfo,
                    recurrenceYN: "N")))
        .sink { data in
            switch data {
            case .failure(let error):
                print(error)
                break
            case .finished:
                break
            }
            self.isLoading = false
        } receiveValue: { response in
            self.editResponse = response
            self.isShowToastMessage = true
            self.changedId = response.economicActivityNo
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.showToast(message: "경제활동 편집 내용을 저장했습니다.")
            }
            completion()
        }.store(in: &cancellable)
    }
    
    func deleteDetailActivity(delRecurrenceYn: String) {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        self.isLoading = true
        APIClient.dispatch(
            APIRouter.DeleteReqDto(
                headers: APIHeader.Default(
                    token: token),
                queryParams: APIParameters.DeleteReqDto(id: id, delRecurrenceYn: delRecurrenceYn)))
        .sink { data in
            switch data {
            case .failure(_):
                break
            case .finished:
                break
            }
            self.isLoading = false
        } receiveValue: { response in
            self.deleteResponse = response
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.showToast(message: "작성한 경제활동을 삭제했습니다.")
            }
        }.store(in: &cancellable)

    }
}

