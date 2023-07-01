//
//  ToastView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/06/21.
//

import UIKit
import Combine
import Then
import SnapKit

final class SnackView: UIView {
    // MARK: - UI Components
    private lazy var textLabel = UILabel()
    private lazy var retryButton = UIButton()
    private lazy var stackView = UIStackView()
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    private var viewModel: AnyObject
    private var idList: [String]?
    private var index: Int?
    
    init(viewModel: AnyObject) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }
    
    
    convenience init(viewModel: AnyObject, idList: [String], index: Int) {
        self.init(viewModel: viewModel)
        self.idList = idList
        self.index = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SnackView {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
        retryButton.tapPublisher
            .sinkOnMainThread { [weak self] in
                guard let self = self else { return }
                
                switch viewModel {
                case let vm as HomeDetailViewModel:
                    guard let list = self.idList else { return }
                    guard let i = self.index else { return }
                    vm.fetchDetailActivity(id: list[i])
				case let vm as ProfileViewModel:
					vm.exportToExcel()
                default:
                    print("error type")
                }
                
            }.store(in: &cancellable)
    }
    
    private func setAttribute() {
        addSubviews(stackView)
        stackView.addArrangedSubviews(textLabel, retryButton)
        
        stackView = stackView.then {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.alignment = .fill
            $0.distribution = .equalSpacing
        }
        
        textLabel = textLabel.then {
            $0.text = "일시적인 오류가 발생했습니다."
            $0.numberOfLines = 2
            $0.textColor = R.Color.white
            $0.font = R.Font.body1
        }
        
        retryButton = retryButton.then {
            $0.setTitle("재시도", for: .normal)
            $0.setTitleColor(R.Color.orange500, for: .normal)
            $0.titleLabel?.font = R.Font.title3
            $0.setTitleColor(R.Color.gray500, for: .highlighted)
		}
	}
	
	private func setLayout() {
		stackView.snp.makeConstraints {
			$0.top.bottom.left.right.equalToSuperview()
		}
        
        textLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
        }
        
        // FIXME: - padding 수정 필요
         retryButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(16)
        }
    }
}
