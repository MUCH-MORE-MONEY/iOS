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
    
    enum FinActAddPage {
        static let start = "FinActAddPage_start"
        static let viewDetail = "FinActAddPage_view_detail"
        static let complete = "FinActAddPage_complete"
        
        static let nextBtnRating = "FinActAddPage_nextbtn_rating"
        static let nextBtnCategory = "FinActAddPage_nextbtn_category"
        static let nextBtnDate = "FinActAddPage_nextbtn_date"
        static let nextBtnAmount = "FinActAddPage_nextbtn_amount"
        
        static let inputCategory = "FinActAddPage_input_category"
        static let inputDate = "FinActAddPage_input_date"
        static let inputAmount = "FinActAddPage_input_amount"
        static let inputTitle = "FinActAddPage_input_title"
        static let inputPhoto = "FinActAddPage_input_photo"
        static let inputRating = "FinActAddPage_input_rating"
        static let inputMemo = "FinActAddPage_input_memo"
    }
}
