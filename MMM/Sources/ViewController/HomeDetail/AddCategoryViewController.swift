//
//  AddCategoryViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 10/16/23.
//

import UIKit
import SnapKit
import Then
import Combine

final class AddCategoryViewController: UIViewController {
    // MARK: - Properties
    private lazy var cancellables: Set<AnyCancellable> = .init()
    private var isDark: Bool = false
    private var viewModel: AnyObject
    private let addCategoryViewModel = AddCategoryViewModel()
    weak var delegate: BottomSheetChild?
    // MARK: - UI Components
    private lazy var stackView = UIStackView() //Label, 확인 Button
    private lazy var titleLabel = UILabel()
    private lazy var buttonStackView = UIStackView()
    private lazy var manageButton = UIButton()
    private lazy var checkButton = UIButton()
    
    init(viewModel: AnyObject) {
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
        setup()
    }

}

// MARK: - Action
extension AddCategoryViewController {
    private func willDismiss() {
        delegate?.willDismiss()
    }
}

//MARK: - Attribute & Hierarchy & Layouts
private extension AddCategoryViewController {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
        guard let viewModel = viewModel as? EditActivityViewModel else { return }
        let date = viewModel.createAt
        let dvcd = viewModel.type
        
        addCategoryViewModel.getCategoryList(date: date, dvcd: dvcd)
        
        checkButton.tapPublisher
            .sinkOnMainThread(receiveValue: willDismiss)
            .store(in: &cancellables)
        
        manageButton.tapPublisher
            .sinkOnMainThread { _ in
                print("관리 버튼 Tapped")
            }
            .store(in: &cancellables)
    }
    
    private func setAttribute() {
        self.view.backgroundColor = isDark ? R.Color.gray900 : .white

        stackView = stackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalCentering
        }
        
        titleLabel = titleLabel.then {
            $0.text = "카테고리 선택"
            $0.font = R.Font.h5
            $0.textColor = isDark ? R.Color.gray200 : R.Color.black
            $0.textAlignment = .left
        }
        
        buttonStackView = buttonStackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 24
        }
        
        checkButton = checkButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
            $0.contentHorizontalAlignment = .right
            $0.titleLabel?.font = R.Font.title3
//            $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
        }
        manageButton = manageButton.then {
            $0.setTitle("관리", for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
            $0.contentHorizontalAlignment = .right
            $0.titleLabel?.font = R.Font.title3
//            $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
        }
    }
    
    private func setLayout() {
        stackView.addArrangedSubviews(titleLabel, buttonStackView)
        buttonStackView.addArrangedSubviews(manageButton, checkButton)
        view.addSubviews(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(28)
        }
    }
}
