//
//  ToastView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/06/28.
//

import UIKit
import SnapKit

final class ToastView: BaseView {
    // MARK: - UI Components
    private lazy var toastLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    
    // MARK: - Properties
    private var toastMessage: String
    
    init(toastMessage: String) {
        self.toastMessage = toastMessage
        super.init(frame: .zero)
    }
}
//MARK: - Attribute & Hierarchy & Layouts
extension ToastView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
        
        toastLabel = toastLabel.then {
            $0.text = toastMessage
            $0.backgroundColor = R.Color.black.withAlphaComponent(0.8)
            $0.font = R.Font.body1
            $0.textColor = R.Color.white
            $0.alpha = 1.0
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
    }
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(toastLabel)
	}
    
	override func setLayout() {
		super.setHierarchy()
		
        toastLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
