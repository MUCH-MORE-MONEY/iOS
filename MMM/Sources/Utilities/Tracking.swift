//
//  Tracking.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/07/02.
//

import Foundation
import FirebaseAnalytics

enum Tracking {
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
        
        /// 경제활동 작성 페이지를 오픈하는 버튼을 클릭 시 발생하는 로그 이벤트
        static func startLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.start,
                               parameters: nil)
        }
        /// 금액 작성을 완료할 시 발생하는 로그 이벤트
        static func inputAmountLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.inputAmount,
                               parameters: nil)
        }
        /// 금액 작성 완료 후 활성화되는 ‘다음’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func nextBtnAmountLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.nextBtnAmount,
                               parameters: nil)
        }
        /// 날짜 설정을 완료할 시 발생하는 로그 이벤트
        static func inputDateLogEvent(_ date: String) {
            Analytics.logEvent(Tracking.FinActAddPage.inputDate,
                               parameters: ["date": date])
        }
        /// 날짜 설정 완료 후 활성화되는 ‘확인’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func nextBtnDateLogEvent(_ date: String) {
            Analytics.logEvent(Tracking.FinActAddPage.nextBtnDate,
                               parameters: ["date": date])
        }
        /// 경제활동 성격 선택 시 발생하는 로그 이벤트
        static func inputCategoryLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.FinActAddPage.inputCategory,
                               parameters: ["type": typeStr])
        }
        /// 경제활동 성격 선택 완료 후 활성화되는 ‘다음’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func nextBtnCategoryLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.FinActAddPage.nextBtnCategory,
                               parameters: ["type": typeStr])
        }
        /// 필수 경제활동 입력 페이지 이후 상세 입력 페이지 오픈 시 발생하는 로그 이벤트
        static func viewDetailLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.viewDetail,
                               parameters: nil)
        }
        /// 제목 입력을 완료할 시  발생하는 로그 이벤트
        static func inputTitleLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.inputTitle,
                               parameters: nil)
        }
        /// 별점 입력 시 발생하는 로그 이벤트
        static func inputRatingLogEvent(_ star: Int) {
            Analytics.logEvent(Tracking.FinActAddPage.inputRating,
                               parameters: ["star": star])
        }
        /// 별점 입력 후 활성화되는 ‘확인’ 버튼을 클릭 시 로그 이벤트
        static func nextBtnRatingLogEvent(_ star: Int) {
            Analytics.logEvent(Tracking.FinActAddPage.nextBtnRating,
                               parameters: ["star": star])
        }
        /// 사진 첨부 시 발생하는 로그 이벤트
        static func inputPhotoLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.FinActAddPage.inputPhoto,
                               parameters: nil)
        }
        /// 사진 첨부 시 발생하는 로그 이벤트
        static func inputMemoLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.FinActAddPage.inputMemo,
                               parameters: nil)
        }
        /// 사진 첨부 시 발생하는 로그 이벤트
        static func completeLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.FinActAddPage.complete,
                               parameters: nil)
        }
    }
    enum CalSetting {
        static let toggleHighlight = "CalSetting_toggle_highlight"
        static let toggleDaySum = "CalSetting_toggle_daySum"
        static let income = "CalSetting_Income"
        static let expense = "CalSetting_Expense"

        /// 금액 하이라이트 설정값 발생하는 로그 이벤트
        static func toogleHighlightLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.CalSetting.toggleHighlight,
                               parameters: nil)
        }
        /// 수입 하이라이트 금액 변경 후 ‘확인’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func incomeLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.CalSetting.income,
                               parameters: nil)
        }
        /// 지출 하이라이트 금액 변경 후 ‘확인’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func expenseLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.CalSetting.expense,
                               parameters: nil)
        }
        /// 일별 금액 합계 설정값 발생하는 로그 이벤트
        static func toggleDaySumLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.CalSetting.toggleDaySum,
                               parameters: nil)
        }
    }
}
