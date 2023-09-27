//
//  CustomPushTimeSettingViewController.swift
//  MMM
//
//  Created by yuraMacBookPro on 2023/09/27.
//

import UIKit
import SnapKit
import Then
import ReactorKit

final class CustomPushTimeSettingViewController: BottomSheetViewController2, View {
    typealias Reactor = CustomPushTimeSettingReactor
    // MARK: - Properties
    private var titleStr: String = ""
    private var isDark: Bool = false
    private var height: CGFloat
    private var textFieldText: String = ""
    
    // MARK: - UI Components
    private lazy var containerView = UIView()
    private lazy var stackView = UIStackView() // label & 확인 버튼
    private lazy var checkButton = UIButton()
    
    init(title: String = "", height: CGFloat, sheetMode: BottomSheetViewController2.Mode = .drag, isDark: Bool = false) {
        self.titleStr = title
        self.height = height
        self.isDark = isDark
        super.init(mode: sheetMode, isDark: isDark)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func bind(reactor: CustomPushTimeSettingReactor) {
        bindAction(reactor)
        bindState(reactor)
    }

}

// MARK: - Bind
extension CustomPushTimeSettingViewController {
    private func bindAction(_ reactor: CustomPushTimeSettingReactor) {
        
    }
    
    private func bindState(_ reactor: CustomPushTimeSettingReactor) {
        
    }
}
