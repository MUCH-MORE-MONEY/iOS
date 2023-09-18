//
//  DataExportViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Combine
import Then
import SnapKit
import Lottie

final class DataExportViewController: BaseViewController {
	// MARK: - Properties
	private let viewModel = ProfileViewModel()
	private lazy var cancellable: Set<AnyCancellable> = .init()

    // MARK: - UI components
    private lazy var mainLabel = UILabel()
    private lazy var subLabel = UILabel()
    private lazy var exportButton = UIButton()
	private lazy var loadView = LoadingViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
}
// MARK: - Action
private extension DataExportViewController {
    func presentShareSheet(_ fileName: String, _ data: Data) {
        // 데이터를 넘겨야함 -> sample data
        // 실제 데이터를 넘길경우 비동기 처리를 해줘야함
		do {
			let fileManager = FileManager.default
			
			// 앱 경로
			let downloadUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
			
			// 파일 경로 생성
			let fileUrl = downloadUrl.appendingPathComponent("\(fileName)")
			try data.write(to: fileUrl, options: .atomic)
			
			let vc = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
			loadView.dismiss(animated: false)
			present(vc, animated: true)
		} catch {
			loadView.dismiss(animated: false)
		}
    }
	
	/// 네트워크 오류시 Toast 노출
//	func showToast() {
//		let toastView = ToastView(toastMessage: "일시적인 오류가 발생했습니다.")
//		toastView.setSnackAttribute()
//		
//		self.view.addSubview(toastView)
//
//		toastView.snp.makeConstraints {
//			$0.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
//			$0.bottom.equalTo(exportButton.snp.top).offset(-16)
//			$0.height.equalTo(40)
//		}
//
//		toastView.toastAnimation(duration: 1.0, delay: 3.0, option: .curveEaseOut)
//	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension DataExportViewController {
	// 초기 셋업할 코드들
    private func setup() {
		bind()
        setAttribute()
        setLayout()
    }
	
	private func bind() {
		//MARK: input
		exportButton.tapPublisher
			.sinkOnMainThread(receiveValue: {
				self.viewModel.exportToExcel()
			})
			.store(in: &cancellable)
		
		//MARK: output
		viewModel.$isLoading
			.sinkOnMainThread(receiveValue: { [weak self] loading in
				guard let self = self else { return }
				
				if loading && !self.loadView.isPresent {
					self.loadView.play()
					self.loadView.setLabel(label: "데이터 내보내는 중...")
					self.loadView.isPresent = true
					self.loadView.modalPresentationStyle = .overFullScreen
					self.present(self.loadView, animated: false)
				} else {
					self.loadView.dismiss(animated: false)
				}
			}).store(in: &cancellable)

		viewModel.$file
			.sinkOnMainThread(receiveValue: { [weak self] file in
				guard let self = self, let file = file else { return }
				presentShareSheet(file.fileName, file.data)
			}).store(in: &cancellable)
		
		viewModel.$isError
			.sinkOnMainThread(receiveValue: { [weak self] isError in
				guard let self = self, let isError = isError else { return }
				if isError {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.window?.showToast(message: "일시적인 오류가 발생했습니다.")
                    }
                } // 네트워크 에러 발생
			}).store(in: &cancellable)
	}
    
    private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
        navigationItem.title = "데이터 내보내기"
        
		mainLabel = mainLabel.then {
			$0.text = "데이터를 엑셀 파일로 내보내어 자유롭게 사용할 수 있어요."
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
			$0.numberOfLines = 2
		}
		
		subLabel = subLabel.then {
			let attrString = NSMutableAttributedString(string: "기록한 경제활동 내역의 제목, 수입/지출, 상세 정보를 엑셀 파일로 첨부하여 메일로 전송합니다.")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 2
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray800
			$0.numberOfLines = 2
		}
		
		exportButton = exportButton.then {
			$0.setTitle("데이터 내보내기", for: .normal)
			$0.titleLabel?.font = R.Font.title1
			$0.backgroundColor = R.Color.gray900
			$0.setButtonLayer()
		}
    }
    
    private func setLayout() {
		view.addSubviews(mainLabel, subLabel, exportButton)

        mainLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.left.right.equalToSuperview().inset(24)
        }
            
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(24)
        }
        
        exportButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(58)
            $0.height.equalTo(56)
        }
    }
}
