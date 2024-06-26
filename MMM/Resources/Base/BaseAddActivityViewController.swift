//
//  BaseAddActivityViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/18.
//

import UIKit
import SnapKit
import Then
import Combine

class BaseAddActivityViewController: BaseDetailViewController {
    // MARK: - UI Components
    lazy var titleTextFeild = UITextField()
    lazy var starStackView = UIStackView()
    lazy var cameraImageView = AddImageView()
    lazy var mainImageView = UIImageView()
    private lazy var cameraButtonStackView = UIStackView()
    lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var addImageButton = UIButton()
    lazy var memoTextView = UITextView()
    lazy var saveButton = UIButton()
    lazy var satisfyingLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12))
    lazy var addCategoryView = AddCategoryView()
    lazy var addScheduleTapView = AddScheduleTapView()
    private lazy var separatorView = SeparatorView()
    
    // MARK: - Properties
    lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16)
    ]
    var textViewPlaceholder = "어떤 경제활동이었나요?\n남기고 싶은 내용이나 감정을 기록해보세요."
    var hasImage = false
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        titleTextFeild.becomeFirstResponder() // 키보드 보이기 및 포커스 주기
    }
}

// MARK: - Action
extension BaseAddActivityViewController {

    /// mainImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    func remakeConstraintsByMainImageView() {
        mainImageView.isHidden = false
        cameraImageView.isHidden = true
        
        guard let image = mainImageView.image else { return }
        
        let aspectRatio = image.size.width / image.size.height
        
        // 높이 제약 조건을 업데이트하여 원본 비율 유지
        self.mainImageView.snp.remakeConstraints {
            $0.top.equalTo(self.starStackView.snp.bottom).offset(16)
            $0.width.equalTo(self.view.safeAreaLayoutGuide).offset(-48)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(self.mainImageView.snp.width).dividedBy(aspectRatio)
        }
        
        memoTextView.snp.remakeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    /// cameraImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    func remakeConstraintsByCameraImageView() {
        cameraImageView.isHidden = false
        mainImageView.isHidden = true
        
        memoTextView.snp.remakeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

//MARK: - Attribute & Hierarchy & Layouts
extension BaseAddActivityViewController {
    override func setAttribute() {
        super.setAttribute()
        // titleTextField 헤더뷰에 넣기
        
        view.addSubviews(titleTextFeild, scrollView, saveButton)
        
        contentView.addSubviews(addScheduleTapView, addCategoryView, separatorView, starStackView, satisfyingLabel, mainImageView, cameraImageView, memoTextView)
        
        starList.forEach {
            $0.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview($0)
        }
        
        scrollView.addSubview(contentView)
        
        
        scrollView = scrollView.then {
            $0.showsVerticalScrollIndicator = false
        }
        
        titleTextFeild = titleTextFeild.then {
            $0.font = R.Font.body0
            $0.textColor = R.Color.gray200
            $0.attributedPlaceholder = NSAttributedString(string: "경제활동의 제목을 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor : R.Color.gray400])
            $0.keyboardType = .webSearch
//            $0.delegate = self
        }
        
        starStackView = starStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 7.54
        }
        
        cameraImageView = cameraImageView.then {
            $0.backgroundColor = R.Color.gray100
            $0.isHidden = true
        }
        
        mainImageView = mainImageView.then {
            $0.image = R.Icon.camera48
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.isUserInteractionEnabled = true
            $0.clipsToBounds = true
        }
        
        memoTextView = memoTextView.then {
            $0.font = R.Font.body3
            $0.textColor = R.Color.gray400
            $0.text = textViewPlaceholder
            $0.translatesAutoresizingMaskIntoConstraints = true
            $0.sizeToFit()
            $0.isScrollEnabled = false
            $0.backgroundColor = R.Color.gray100
            $0.keyboardType = .webSearch
        }
        
        saveButton = saveButton.then {
            $0.setTitle("활동 저장하기", for: .normal)
            $0.backgroundColor = R.Color.gray800
            $0.setTitleColor(R.Color.gray100, for: .normal)
            $0.titleLabel?.font = R.Font.title1
        }
        // CameraImageView와 ViewModel 공유
        
        satisfyingLabel = satisfyingLabel.then {
            $0.backgroundColor = R.Color.gray600
            $0.font = R.Font.body4
            $0.textColor = R.Color.gray300
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = true
        }
    }
    
    override func setLayout() {
        super.setLayout()
        // FIXME: -title Text의 위치를 대충 잡아버림
        titleTextFeild.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(totalPrice.snp.top).offset(-20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addCategoryView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        addScheduleTapView.snp.makeConstraints {
            $0.top.equalTo(addCategoryView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(addScheduleTapView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(16)
            $0.left.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(24)
        }
        
        satisfyingLabel.snp.makeConstraints {
            $0.left.equalTo(starStackView.snp.right).offset(4)
            $0.centerY.equalTo(starStackView)
        }
        
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.width.equalTo(view.safeAreaLayoutGuide).offset(-48)
            $0.height.equalTo(mainImageView.snp.width)
            //            $0.height.equalTo(mainImageView.image!.size.height * view.frame.width / mainImageView.image!.size.width)
            $0.left.right.equalToSuperview()
        }
        
        cameraImageView.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(144)
        }
        
        memoTextView.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(58)
            $0.height.equalTo(56)
        }
    }
}

// MARK: - Textfield Delegate
extension BaseAddActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 내리기
        return true
    }
}
