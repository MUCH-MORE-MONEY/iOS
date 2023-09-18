//
//  DataExportViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class DataExportViewController: BaseViewControllerWithNav, View {
	typealias Reactor = ProfileReactor

	// MARK: - Constants
	private enum UI {
		static let mainLabelMargin: UIEdgeInsets = .init(top: 32, left: 24, bottom: 0, right: 24)
		static let subLabelMargin: UIEdgeInsets = .init(top: 32, left: 24, bottom: 0, right: 24)
		static let exportButtonMargin: UIEdgeInsets = .init(top: 0, left: 24, bottom: 58, right: 24)
		static let exportButtonHeight: CGFloat = 56

	}
	
	// MARK: - Properties

    // MARK: - UI components
    private lazy var mainLabel = UILabel()
    private lazy var subLabel = UILabel()
    private lazy var exportButton = UIButton()
	private lazy var loadView = LoadingViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func bind(reactor: ProfileReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension DataExportViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: ProfileReactor) {
		// 데이터 변환 요청
		exportButton.rx.tap
			.map { .export }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: ProfileReactor) {
		// 카테고리 더보기 클릭시, push
		reactor.state
			.compactMap { $0.file }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: presentShareSheet)
			.disposed(by: disposeBag)
		
		// 로딩 발생
		reactor.state
			.map { $0.isLoading }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true 일때만
			.subscribe(onNext: { [weak self] loading in
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
			})
			.disposed(by: disposeBag)
		
		// Error 발생
		reactor.state
			.map { $0.error }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true 일때만
			.subscribe(onNext: { isError in
				if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
					sceneDelegate.window?.showToast(message: "일시적인 오류가 발생했습니다.")
				}
			})
			.disposed(by: disposeBag)
	}
}
// MARK: - Action
private extension DataExportViewController {
	func presentShareSheet(file: ProfileReactor.File) {
        // 데이터를 넘겨야함 -> sample data
        // 실제 데이터를 넘길경우 비동기 처리를 해줘야함
		do {
			let fileManager = FileManager.default
			
			// 앱 경로
			let downloadUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
			
			// 파일 경로 생성
			let fileUrl = downloadUrl.appendingPathComponent("\(file.fileName)")
			try file.data.write(to: fileUrl, options: .atomic)
			
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
extension DataExportViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
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
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(mainLabel, subLabel, exportButton)
	}
    
	override func setLayout() {
		super.setLayout()
		
        mainLabel.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).offset(UI.mainLabelMargin.top)
			$0.leading.trailing.equalToSuperview().inset(UI.mainLabelMargin.left)
        }
            
        subLabel.snp.makeConstraints {
			$0.top.equalTo(mainLabel.snp.bottom).offset(UI.subLabelMargin.top)
			$0.left.right.equalToSuperview().inset(UI.subLabelMargin.left)
        }
        
        exportButton.snp.makeConstraints {
			$0.left.right.equalToSuperview().inset(UI.exportButtonMargin.left)
			$0.bottom.equalToSuperview().inset(UI.exportButtonMargin.bottom)
			$0.height.equalTo(UI.exportButtonHeight)
        }
    }
}
