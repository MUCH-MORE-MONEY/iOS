//
//  Tracking.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/07/02.
//

import Foundation

enum Tracking {
    enum Screen {
        static let home = "홈"
        static let mypage = "마이 페이지"
        static let login = "로그인"
    }
    
    enum Event {
        static let touchAddView = "추가하기 뷰 클릭"
        static let touchDetailView = "상세뷰 클릭"
        static let touchEditView = "편집하기 클릭"
        static let deleteActivity = "경제활동 내역 삭제"
        static let insertActivity = "경제활동 내역 추가"
    }
}
