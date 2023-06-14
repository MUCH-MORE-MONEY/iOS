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
	private let viewModel: ProfileViewModel
	private lazy var cancellable: Set<AnyCancellable> = .init()

    // MARK: - UI components
    private lazy var mainLabel = UILabel()
    private lazy var subLabel = UILabel()
    private lazy var exportButton = UIButton()
	private lazy var loadingLottie: LottieAnimationView = LottieAnimationView(name: "loading")

	init(viewModel: ProfileViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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
			let downloadUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let fileUrl = downloadUrl.appendingPathComponent("\(fileName)")
			try data.write(to: fileUrl, options: .atomic)
			
			let vc = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
			
			viewModel.isLoading = false // 로딩 종료
			present(vc, animated: true)
		} catch {
			viewModel.isLoading = false // 로딩 종료
		}
    }
}
// MARK: - Style & Layouts
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
				
				if loading {
					self.loadingLottie.play()
					self.loadingLottie.isHidden = false
				} else {
					self.loadingLottie.stop()
					self.loadingLottie.isHidden = true
				}
			}).store(in: &cancellable)

		viewModel.$file
			.sinkOnMainThread(receiveValue: { [weak self] file in
				guard let self = self, let file = file else { return }
				presentShareSheet(file.fileName, file.data)
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
		
		loadingLottie = loadingLottie.then {
			$0.stop()
			$0.contentMode = .scaleAspectFit
			$0.loopMode = .loop // 애니메이션을 무한으로 실행
			$0.backgroundColor = R.Color.black.withAlphaComponent(0.3)
			$0.isHidden = true
		}
    }
    
    private func setLayout() {
		view.addSubviews(mainLabel, subLabel, exportButton, loadingLottie)

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
		
		loadingLottie.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
    }
}
