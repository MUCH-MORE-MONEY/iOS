//
//  Tracking.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/07/02.
//

import Foundation
import FirebaseAnalytics

enum Tracking {
    static func setUser(_ id: String) {
        Analytics.setUserID(id)
    }
    
    enum FinActAddPage {
        static let start = "FinActAddPage_start"
        static let viewDetail = "FinActAddPage_view_detail"
        static let complete = "FinActAddPage_complete"
        
        static let nextBtnRating = "FinActAddPage_nextbtn_rating"
        static let nextBtnType = "FinActAddPage_nextbtn_type"
        static let nextBtnDate = "FinActAddPage_nextbtn_date"
        static let nextBtnAmount = "FinActAddPage_nextbtn_amount"
        
        static let inputType = "FinActAddPage_input_type"
        static let inputDate = "FinActAddPage_input_date"
        static let inputAmount = "FinActAddPage_input_amount"
        static let inputTitle = "FinActAddPage_input_title"
        static let inputPhoto = "FinActAddPage_input_photo"
        static let inputRating = "FinActAddPage_input_rating"
        static let inputMemo = "FinActAddPage_input_memo"
        
        static let inputCategory = "FinActAddPage_input_category"
        static let inputCategorySetting = "FinActAddPage_input_category_setting"
        
        /// 경제활동 작성 페이지를 오픈하는 버튼을 클릭 시 발생하는 로그 이벤트
        static func startLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.start,
                               parameters: nil)
        }
        /// 금액 작성을 완료할 시 발생하는 로그 이벤트
        static func inputAmountLogEvent(_ amount: String) {
            Analytics.logEvent(Tracking.FinActAddPage.inputAmount,
                               parameters: ["Amount": amount])
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
        static func nextBtnDateLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.nextBtnDate,
                               parameters: nil)
        }
        /// 경제활동 성격 선택 시 발생하는 로그 이벤트
        static func inputTypeLogEvent(_ type: String) {
            let typeStr = type == "01" ? "지출" : "수입"
            Analytics.logEvent(Tracking.FinActAddPage.inputType,
                               parameters: ["type": typeStr])
        }
        /// 경제활동 성격 선택 완료 후 활성화되는 ‘다음’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func nextBtnTypeLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.nextBtnType,
                               parameters: nil)
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
        static func nextBtnRatingLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.nextBtnRating,
                               parameters: nil)
        }
        /// 사진 첨부 시 발생하는 로그 이벤트
        static func inputPhotoLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.inputPhoto,
                               parameters: nil)
        }
        /// 경제활동 메모 입력을 완료할 시 발생하는 로그 이벤트
        static func inputMemoLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.inputMemo,
                               parameters: nil)
        }
        /// 활동 저장하기 버튼 클릭 시 시 발생하는 로그 이벤트
        static func completeLogEvent() {
            Analytics.logEvent(Tracking.FinActAddPage.complete,
                               parameters: nil)
        }
        /// 카테고리 선택 시
        static func inputCategoryLogEvent() {
            Analytics.logEvent(self.inputCategory, parameters: nil)
        }
        /// 카테고리 바텀시트의 설정 버튼 클릭 시
        static func inputCategorySettingLogEvent() {
            Analytics.logEvent(self.inputCategorySetting, parameters: nil)
        }
    }
    enum CalSetting {
        static let toggleHighlight = "CalSetting_toggle_highlight"
        static let toggleDaySum = "CalSetting_toggle_daySum"
        static let income = "CalSetting_Income"
        static let expense = "CalSetting_Expense"

        /// 금액 하이라이트 설정값 발생하는 로그 이벤트
        static func toggleHighlightLogEvent(_ isOn: Bool) {
            Analytics.logEvent(Tracking.CalSetting.toggleHighlight,
                               parameters: ["isOn": isOn])
        }
        /// 수입 하이라이트 금액 변경 후 ‘확인’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func incomeLogEvent(_ value: Int) {
            Analytics.logEvent(Tracking.CalSetting.income,
                               parameters: ["value": value])
        }
        /// 지출 하이라이트 금액 변경 후 ‘확인’ 버튼을 클릭 시 발생하는 로그 이벤트
        static func expenseLogEvent(_ value: Int) {
            Analytics.logEvent(Tracking.CalSetting.expense,
                               parameters: ["value": value])
        }
        /// 일별 금액 합계 설정값 발생하는 로그 이벤트
        static func toggleDaySumLogEvent(_ isOn: Bool) {
            Analytics.logEvent(Tracking.CalSetting.toggleDaySum,
                               parameters: ["isOn": isOn])
        }
    }
    
    enum StatiBudget {
        static let pageView = "StatiBudget_PageView"
        static let rating12 = "StatiBudget_rating_1,2"
        static let rating45 = "StatiBudget_rating_4,5"
        static let rating3 = "StatiBudget_rating_3"
        static let btnCategory = "StatiBudget_btn_Category"
        
        /// 통계/예산 탭에 들어올 시
        static func pageViewLogEvent() {
            Analytics.logEvent(self.pageView, parameters: nil)
        }
        /// 아쉬운 활동을 설정할 시
        static func rating12LogEvent() {
            Analytics.logEvent(self.rating12, parameters: nil)
        }
        /// 만족스러운 활동을 설정할 시
        static func rating45LogEvent() {
            Analytics.logEvent(self.rating45, parameters: nil)
        }
        /// 평범한 활동을 설정할 시
        static func rating3LogEvent() {
            Analytics.logEvent(self.rating3, parameters: nil)
        }
        /// 통계/예산탭에서 카테고리 영역(더보기)을 선택할 시
        static func btnCategoryLogEvent() {
            Analytics.logEvent(self.btnCategory, parameters: nil)
        }
    }
    
    enum Category {
        static let mainPay = "Category_veiw_main_Pay"
        static let categoryEditPay = "Category_view_CategoryEdit_Pay"
        static let categoryTypeEditPay = "Category_view_CategoryTypeEdit_Pay"
        static let mainEarn = "Category_veiw_main_Earn"
        static let categoryEditEarn = "Category_view_CategoryEdit_Earn"
        static let categoryTypeEditEarn = "Category_view_CategoryTypeEdit_Earn"
        
        /// 카테고리 메인 페이지 (지출) 오픈 시
        static func mainPayLogEvent() {
            Analytics.logEvent(self.mainPay, parameters: nil)
        }
        /// 카테고리 편집 페이지 (지출) 오픈 시
        static func categoryEditPayLogEvent() {
            Analytics.logEvent(self.categoryEditPay, parameters: nil)
        }
        /// 카테고리 유형 편집 페이지 (지출) 오픈 시
        static func categoryTypeEditPayLogEvent() {
            Analytics.logEvent(self.categoryTypeEditPay, parameters: nil)
        }
        /// 카테고리 메인 페이지 (수입) 오픈 시
        static func mainEarnLogEvent() {
            Analytics.logEvent(self.mainEarn, parameters: nil)
        }
        /// 카테고리 편집 페이지 (수입) 오픈 시
        static func categoryEditEarnLogEvent() {
            Analytics.logEvent(self.categoryEditEarn, parameters: nil)
        }
        /// 카테고리 유형 편집 페이지(수입) 오픈 시
        static func categoryTypeEditEarnEvent() {
            Analytics.logEvent(self.categoryTypeEditEarn, parameters: nil)
        }
    }
    
    enum AccountBook {
        static let pageView = "AccountBook_PageView"
        /// 가계부(기존 소비 탭) 오픈 시
        static func pageViewLogEvent() {
            Analytics.logEvent(self.pageView, parameters: nil)
        }
    }
    
    enum NotiSetting {
        static let toggleCustom = "NotiSetting_toggle_Custom"
        static let time = "NotiSetting_Time"
        static let text = "NotiSetting_Text"
        
        /// 맞춤 정보 알림
        static func toggleCustomLogEvent(_ isOn: Bool) {
            Analytics.logEvent(self.toggleCustom, parameters: ["isOn": isOn])
        }
        /// 알림 시간 지정
        static func timeLogEvent() {
            Analytics.logEvent(self.time, parameters: nil)
        }
        /// 알람 문구 지정
        static func textLogEvent() {
            Analytics.logEvent(self.text, parameters: nil)
        }
    }
}
