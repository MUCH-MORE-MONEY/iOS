//
//  EditActivityViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/23.
//

import UIKit
import Photos
import Combine

final class EditActivityViewModel {
    // MARK: - Property Wrapper
    @Published var didTapAddButton: Bool = false
    @Published var isTitleEmpty = false
    // MARK: - API Request를 위한 Property Wrapper
    @Published var title = ""
    @Published var memo = ""
    @Published var id = ""
    @Published var amount = 20000
    @Published var createAt = ""
    @Published var star = 5
    @Published var type = ""
    @Published var fileNo = ""
    @Published var binaryFileList:  [APIParameters.UpdateReqDto.BinaryFileList] = []
  	@Published var date: Date = Date() // picker

    @Published var data: InsertResDto?
    @Published var editResponse: UpdateResDto?
    @Published var deleteResponse: DeleteResDto?
    // MARK: - Porperties
    private var cancellable: Set<AnyCancellable> = []
    lazy var isVaild: AnyPublisher<Bool, Never> = $title
        .map { $0.count <= 16 } // 16자리 이하
        .eraseToAnyPublisher()
    
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
        guard Constants.getKeychainValue(forKey: Constants.KeychainKey.token) != nil else { return }
        
        APIClient.dispatch(
            APIRouter.InsertReqDto(
                headers: APIHeader.Default(token: TempToken.token),
                body: APIParameters.InsertEconomicActivityReqDto(
                    binaryFileList: [],
                    amount: amount,
                    type: type,
                    title: title,
                    memo: memo,
                    createAt: createAt,
                    star: star)))
        .sink { data in
            switch data {
            case .failure(let error):
                break
            case .finished:
                break
            }
        } receiveValue: { response in
            self.data = response
            print(self.data)
        }.store(in: &cancellable)
    }
    
    
    //    경제활동 수정 API
    //    파일유지->fileNo req body에 유지,
    //    파일 삭제-> fileNo=''
    //    파일 변경 -> fileNo='' and BinaryFileList 추가
    func updateDetailActivity() {
        APIClient.dispatch(
            APIRouter.UpdateReqDto(
                headers: APIHeader.Default(token: TempToken.token),
                body: APIParameters.UpdateReqDto(
                    binaryFileList: binaryFileList,
                    amount: amount,
                    type: type,
                    title: title,
                    memo: memo,
                    id: id,
                    createAt: createAt,
                    fileNo: fileNo,
                    star: star)))
        .sink { data in
            switch data {
            case .failure(let error):
                switch error {
                case .error4xx(let code):
                    print("\(code) error")
                case .invalidRequest:
                    print("invalidRequest")
                case .badRequest:
                    print("BadRequest")
                case .unauthorized:
                    print("unauthorized Error")
                case .forbidden:
                    print("forbidden Error")
                case .notFound:
                    print("notFOund Error")
                case .serverError:
                    print("Server Error")
                case .error5xx(let code):
                    print("\(code) error")
                case .decodingError(let code):
                    print("decoding Error : \(code)")
                case .urlSessionFailed(let error):
                    print("urlsession error : \(error.localizedDescription)")
                case .timeOut:
                    print("timeOut")
                case .unknownError:
                    print("Unknown")
                }
                break
            case .finished:
                break
            }
        } receiveValue: { response in
            self.editResponse = response
            print(response)
        }.store(in: &cancellable)
    }
    
    func deleteDetailActivity() {
        APIClient.dispatch(
            APIRouter.DeleteReqDto(
                headers: APIHeader.Default(
                    token: TempToken.token),
                body: APIParameters.DeleteReqDto(id: id)))
        .sink { data in
            switch data {
            case .failure(let error):
                switch error {
                case .error4xx(let code):
                    print("\(code) error")
                case .invalidRequest:
                    print("invalidRequest")
                case .badRequest:
                    print("BadRequest")
                case .unauthorized:
                    print("unauthorized Error")
                case .forbidden:
                    print("forbidden Error")
                case .notFound:
                    print("notFOund Error")
                case .serverError:
                    print("Server Error")
                case .error5xx(let code):
                    print("\(code) error")
                case .decodingError(let code):
                    print("decoding Error : \(code)")
                case .urlSessionFailed(let error):
                    print("urlsession error : \(error.localizedDescription)")
                case .timeOut:
                    print("timeOut")
                case .unknownError:
                    print("Unknown")
                }
                break
            case .finished:
                break
            }
        } receiveValue: { response in
            self.deleteResponse = response
            print(self.deleteResponse)
        }.store(in: &cancellable)

    }
}

