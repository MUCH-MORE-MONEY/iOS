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
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var shadowView = UIView()
    
    // 카테고리 데이터가 없을 경우를 위한 image
    private lazy var emptyImageView = UIImageView()
    private lazy var emptyLabel = UILabel()
    private lazy var emptyStackView = UIStackView()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowView.addTopShadow()
//        shadowView.addTopShadow(color: R.Color.black,
//                                opacity: 0.5,
//                                offset: CGSize(width: 0, height: 2),
//                                radius: 5)
    }
}

// MARK: - Action
extension AddCategoryViewController {
    private func willDismiss() {
        delegate?.willDismiss()
        
        if let editViewModel = viewModel as? EditActivityViewModel {
            editViewModel.categoryName = addCategoryViewModel.selectedCategoryName
            editViewModel.categoryId = addCategoryViewModel.selectedCategoryID
        }
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
        // 뷰가 생성될때 카테고리편집에서 온 경우일수도 있기 때문에 항상 초기화해줌
        viewModel.isViewFromCategoryViewController = false
        
        addCategoryViewModel.getCategoryList(date: date, dvcd: dvcd)
        
        checkButton.tapPublisher
            .sinkOnMainThread(receiveValue: willDismiss)
            .store(in: &cancellables)
        
        manageButton.tapPublisher
            .sinkOnMainThread { [weak self] _ in
                guard let self = self else { return }
                
                if let viewModel = self.viewModel as? EditActivityViewModel {
                    delegate?.willDismiss()
                    viewModel.isCategoryManageButtonTapped = true
                }
                print("관리 버튼 Tapped")
            }
            .store(in: &cancellables)
        
        addCategoryViewModel.$categoryList
            .sink { [weak self] list in
                guard let self = self else { return }
                if list.isEmpty {
                    
                } else {
                    self.collectionView.isHidden = false
                    self.emptyStackView.isHidden = true
                    self.collectionView.reloadData()
                }
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
        
        collectionView = collectionView.then {
            let layer = LeftAlignedCollectionViewFlowLayout()
            layer.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
            $0.showsVerticalScrollIndicator = false
            $0.collectionViewLayout = layer
            $0.backgroundColor = R.Color.white
            $0.delegate = self
            $0.dataSource = self
            $0.register(CategorySelectCell.self, forCellWithReuseIdentifier: "CategorySelectCell")
            $0.register(CategorySelectHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategorySelectHeaderCell")
            $0.isScrollEnabled = true
            $0.isHidden = true
        }
        
        emptyStackView = emptyStackView.then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 16
        }
        
        emptyImageView = emptyImageView.then {
            $0.image = R.Icon.iconCharacterEmptyCategory
            $0.contentMode = .scaleAspectFit
        }
        
        emptyLabel = emptyLabel.then {
            $0.text = "선택할 수 있는 카테고리가 없어요.\n관리 페이지에서 추가해주세요!"
            $0.numberOfLines = 0
            $0.font = R.Font.body1
            $0.textColor = R.Color.gray400
            $0.textAlignment = .center
        }
    }
    
    private func setLayout() {
        stackView.addArrangedSubviews(titleLabel, buttonStackView)
        buttonStackView.addArrangedSubviews(manageButton, checkButton)
        emptyStackView.addArrangedSubviews(emptyImageView, emptyLabel)
        view.addSubviews(stackView, collectionView, shadowView, emptyStackView)
        
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(28)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-58)
        }
        
        shadowView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        emptyStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

extension AddCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addCategoryViewModel.categoryList.isEmpty ? 0 : addCategoryViewModel.categoryList[section].lowwer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategorySelectCell", for: indexPath) as? CategorySelectCell else { return UICollectionViewCell()}
        
        let title = addCategoryViewModel.categoryList[indexPath.section].lowwer[indexPath.item].title
        
        if let viewModel = viewModel as? EditActivityViewModel {
            cell.setData(title, viewModel.type == "01")
            
            if viewModel.categoryName == title {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // header
        let title = addCategoryViewModel.categoryList[indexPath.section].title
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "CategorySelectHeaderCell",
                    for: indexPath) as? CategorySelectHeaderCell else { return CategorySelectHeaderCell() }
            header.setData(title)
            return header
        } else { // footer
            guard let footer = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: "CategorySelectHeaderCell",
                    for: indexPath) as? CategorySelectHeaderCell else { return CategorySelectHeaderCell() }
            footer.setData(title)
            return footer
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return addCategoryViewModel.categoryList.isEmpty ? 0 : addCategoryViewModel.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addCategoryViewModel.selectedCategoryID = addCategoryViewModel.categoryList[indexPath.section].lowwer[indexPath.item].id
        addCategoryViewModel.selectedCategoryName = addCategoryViewModel.categoryList[indexPath.section].lowwer[indexPath.item].title
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }

        let offsetY = collectionView.contentOffset.y
        let contentHeight = collectionView.contentSize.height
        let frameHeight = collectionView.frame.size.height
        
        // 하단에 도달했는지 여부 확인
        if offsetY > contentHeight - frameHeight - 1 {
            // 스크롤이 거의 끝에 도달했을 때
            shadowView.isHidden = true
        } else {
            // 그렇지 않으면 그림자 제거
//            gradientLayer.isHidden = true
            shadowView.isHidden = false
        }
    }
}

// MARK: - UICollectionView DelegateFlowLayout
extension AddCategoryViewController: UICollectionViewDelegateFlowLayout {
    // 지정된 섹션의 헤더뷰의 크기를 반환하는 메서드. 크기를 지정하지 않으면 화면에 보이지 않습니다.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width , height: 24)
    }

    // 지정된 섹션의 여백을 반환하는 메서드.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
    }

    // 지정된 섹션의 셀 사이의 최소간격을 반환하는 메서드.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // 지정된 섹션의 행 사이 간격 최소 간격을 반환하는 메서드. scrollDirection이 horizontal이면 수직이 행이 되고 vertical이면 수평이 행이 된다.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    // 지정된 셀의 크기를 반환하는 메서드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 셀의 내용이 될 텍스트
        let text = addCategoryViewModel.categoryList[indexPath.section].lowwer[indexPath.item].title

        // 설정할 최대 너비
        let maxWidth = collectionView.bounds.width
        // 여기서는 컬렉션 뷰의 너비를 최대 너비로 사용했지만,
        // 여러분의 레이아웃에 따라 다를 수 있습니다.
        
        // 레이블의 패딩이나 마진을 조정
        let labelInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 30)
        
        // 텍스트에 기반한 레이블의 크기를 계산합니다.
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let attributes = [NSAttributedString.Key.font: R.Font.body3]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        // 최종 셀의 너비는 레이블의 계산된 너비 + 좌우 패딩
        let cellWidth = ceil(estimatedFrame.width + labelInsets.left + labelInsets.right)
        
        // 최종 셀의 높이는 레이블의 계산된 높이 + 상하 패딩 (여기서는 예시로 셀의 높이를 고정값으로 설정)
        let cellHeight: CGFloat = 32
        
        // 최종 셀 사이즈 반환
        return CGSize(width: cellWidth + 2, height: cellHeight)
    }
}
