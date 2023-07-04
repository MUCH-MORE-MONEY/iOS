//
//  Ex+Window.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/07/04.
//

import UIKit

extension UIWindow {
    func showToast() {
        let message = "경제활동 편집 내용을 저장했습니다."
        let toastView = ToastView(toastMessage: message)
        self.addSubview(toastView)

        toastView.snp.makeConstraints {
            $0.left.right.equalTo(safeAreaLayoutGuide).inset(24)
            $0.bottom.equalToSuperview().offset(-106)
        }

        toastView.toastAnimation(duration: 1.0, delay: 3.0, option: .curveEaseOut)
    }
}
