//
//  EditText.swift
//  MMM
//
//  Created by yuraMacBookPro on 4/5/24.
//

import Foundation

enum AlertText {
    enum Edit {
        static let title = "편집을 그만두시겠어요?"
        static let message = "편집한 내용이 사라지니 유의해주세요!"
        static let cancel = "편집 취소하기"
    }
    
    enum Delete {
        static let title = "경제활동을 삭제하시겠어요?"
        static let message = "활동이 영구적으로 사라지니 유의해주세요!"
        static let confirm = "삭제하기"
    }
    
    static let close = "닫기"
}
