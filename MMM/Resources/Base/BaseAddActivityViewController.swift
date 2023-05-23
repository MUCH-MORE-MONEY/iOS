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
    private lazy var starStackView = UIStackView()
    lazy var cameraImageView = AddImageView()
    lazy var mainImageView = UIImageView()
    private lazy var cameraButtonStackView = UIStackView()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var addImageButton = UIButton()
    lazy var memoTextView = UITextView()
    private lazy var saveButton = UIButton()
    // MARK: - Properties
    lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive)
    ]
    var hasImage = false
    private var cancellable = Set<AnyCancellable>()
    private var imagePickerVC = UIImagePickerController()
    private var viewModel = AddActivityViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Style & Layout
extension BaseAddActivityViewController {
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func setAttribute() {
        // titleTextField 헤더뷰에 넣기

        view.addSubviews(titleTextFeild, scrollView, saveButton)
        
        contentView.addSubviews(starStackView, mainImageView, cameraImageView, memoTextView)
        
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

        }
        
        starStackView = starStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 7.54
        }
        
        cameraImageView = cameraImageView.then {
            $0.backgroundColor = R.Color.gray100
        }
        
        mainImageView = mainImageView.then {
            $0.contentMode = .scaleToFill
        }
        
        memoTextView = memoTextView.then {
            $0.font = R.Font.body3
            $0.textColor = R.Color.gray400
            $0.text = "어떤 경제활동이었나요?\n남기고 싶은 내용이나 감정을 기록해보세요."
            $0.translatesAutoresizingMaskIntoConstraints = true
            $0.sizeToFit()
            $0.isScrollEnabled = false
            $0.backgroundColor = R.Color.gray100
        }
        
        saveButton = saveButton.then {
            $0.setTitle("활동 저장하기", for: .normal)
            $0.backgroundColor = R.Color.gray800
            $0.setTitleColor(R.Color.gray100, for: .normal)
            $0.titleLabel?.font = R.Font.title1
            $0.setButtonLayer()
            $0.isEnabled = false
        }
        // CameraImageView와 ViewModel 공유
    }
    
    private func setLayout() {
        titleTextFeild.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(totalPrice.snp.top).offset(-20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(saveButton.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.width.equalTo(120)
            $0.height.equalTo(24)
        }
        
        if hasImage {
            mainImageView.snp.makeConstraints {
                $0.top.equalTo(starStackView.snp.bottom).offset(16)
                $0.width.equalTo(view.safeAreaLayoutGuide).offset(-48)
                $0.height.equalTo(mainImageView.image!.size.height * view.frame.width / mainImageView.image!.size.width)
                $0.left.right.equalToSuperview()
            }
        } else {

        }
        
        cameraImageView.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(144)
        }

        memoTextView.snp.makeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(58)
            $0.height.equalTo(56)
        }
    }
    
    /// mainImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    func remakeConstraintsByMainImageView() {
        cameraImageView.isHidden = true
        
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.width.equalTo(view.safeAreaLayoutGuide).offset(-48)
            $0.height.equalTo(mainImageView.image!.size.height * view.frame.width / mainImageView.image!.size.width)
            $0.left.right.equalToSuperview()
        }
        memoTextView.snp.remakeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    /// cameraImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    func remakeConstraintsByCameraImageView() {
        mainImageView.isHidden = true

        cameraImageView.snp.updateConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(144)
        }
        
        memoTextView.snp.remakeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        cameraImageView.setData(viewModel: viewModel)
        viewModel.$didTapAddButton
            .sinkOnMainThread(receiveValue: { [weak self] in
                guard let self = self else { return }
                if $0 {
                    viewModel.requestPHPhotoLibraryAuthorization {
                        DispatchQueue.main.async {
                            self.showPicker()
                        }
                    }
                }
            })
            .store(in: &cancellable)
    }
    
    func showPicker() {
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true)
    }
}

extension BaseAddActivityViewController: UIImagePickerControllerDelegate {
    
}
