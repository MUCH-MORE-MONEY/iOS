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

final class AddActivityViewController: BaseDetailViewController {
    // MARK: - UI Components
    private lazy var titleTextFeild = UITextField()
    private lazy var starStackView = UIStackView()
    private lazy var starLabelStackView = UIStackView()
    private lazy var satisfactionLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12))
    private lazy var cameraImageView = CameraImageView()
    private lazy var cameraButtonStackView = UIStackView()
    private lazy var scrollView = UIScrollView()
    private lazy var addImageButton = UIButton()
    private lazy var memoTextView = UITextView()
    private lazy var saveButton = UIButton()
    // MARK: - Properties
    private lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Style & Layout
extension AddActivityViewController {
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    func setData(title: String, price: String, memo: String, star: Int) {
        titleTextFeild.text = title
        self.memoTextView.text = memo

        DispatchQueue.main.async {
            self.totalPrice.text = price
        }
        
        for i in 0..<star {
            self.starList[i].image = R.Icon.iconStarBlack24
        }
    }
    
    private func setAttribute() {
        view.addSubviews(titleTextFeild, scrollView, saveButton)
        
        scrollView.addSubviews(starLabelStackView, cameraImageView, memoTextView)
        
        
        starList.forEach {
            $0.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview($0)
        }
    
        let star = starList.filter{ $0.image == R.Icon.iconStarActive}.count

        satisfactionLabel.setSatisfyingLabel(by: star)
        
        starLabelStackView.addArrangedSubviews(starStackView, satisfactionLabel)
        
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
        
        satisfactionLabel = satisfactionLabel.then {
            $0.backgroundColor = R.Color.gray700
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.textColor = R.Color.gray100
            $0.font = R.Font.body4
        }
        
        starLabelStackView = starLabelStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
        }
        
        memoTextView = memoTextView.then {
            $0.font = R.Font.body3
            $0.textColor = R.Color.gray400
            $0.text = "어떤 경제활동이었나요?\n남기고 싶은 내용이나 감정을 기록해보세요."
        }
        
        saveButton = saveButton.then {
            $0.setTitle("활동 저장하기", for: .normal)
            $0.backgroundColor = R.Color.gray800
            $0.setTitleColor(R.Color.gray100, for: .normal)
            $0.titleLabel?.font = R.Font.title1
            $0.setButtonLayer()
            $0.isEnabled = false
        }
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
        
        starStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(24)
            $0.width.equalTo(120)
        }
        
        starLabelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview()
        }
        
        cameraImageView.snp.makeConstraints {
            $0.top.equalTo(starLabelStackView.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(144)
            $0.width.equalToSuperview()
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
    
    private func bind() {
        
    }
}
