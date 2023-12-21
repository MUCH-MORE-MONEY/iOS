//
//  DetailViewController2.swift
//  MMM
//
//  Created by yuraMacBookPro on 12/21/23.
//

import UIKit
import Then
import SnapKit
import RxSwift
import Lottie
import ReactorKit

final class DetailViewController2: BaseDetailViewController, UIScrollViewDelegate {
    
    // MARK: - UI Components
    private lazy var starStackView = UIStackView()
    private lazy var editActivityButtonItem = UIBarButtonItem()
    private lazy var editButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var satisfactionLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12))
    private lazy var mainImageView = UIImageView()
    private lazy var cameraImageView = CameraImageView()
    private lazy var bottomPageControlView = BottomPageControlView()
    private lazy var memoLabel = UILabel()
    private lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16)
    ]
    lazy var addCategoryView = AddCategoryView()
    private lazy var separatorView = SeparatorView()
    
    // MARK: - LoadingView
    private lazy var loadView = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - Action
private extension DetailViewController2 {
//    func didTapEditButton() {
//        if cameraImageView.isHidden {
//            let mainImage = mainImageView.image
//            homeDetailViewModel.mainImage = mainImage
//        } else {
//            homeDetailViewModel.mainImage = nil
//        }
//        
//        let vc = EditActivityViewController(detailViewModel: homeDetailViewModel, editViewModel: editViewModel, date: date)
//        
//        navigationController?.pushViewController(vc, animated: true)
//    }
}

// MARK: - Loading Func
extension DetailViewController2 {
//    func showSnack() {
//        let snackView = SnackView(viewModel: homeDetailViewModel, idList: economicActivityId, index: index)
//        snackView.setSnackAttribute()
//        self.view.addSubview(snackView)
//        snackView.snp.makeConstraints {
//            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
//            $0.bottom.equalTo(bottomPageControlView.snp.top).offset(-16)
//            $0.height.equalTo(40)
//        }
//        
//        snackView.toastAnimation(duration: 1.0, delay: 3.0, option: .curveEaseOut)
//    }
//    
//    func showLoadingView() {
//        self.loadView.play()
//        self.loadView.isPresent = true
//        self.loadView.modalPresentationStyle = .overFullScreen
//        self.present(self.loadView, animated: false)
//    }
}
