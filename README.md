# 🍢 MMM
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)

## 👋 앱 소개

<p align="center"><img src="https://user-images.githubusercontent.com/48436020/219564198-f7c5214b-712b-47c7-9e4e-a2070007cb81.png" width=30%></p>

```
 수기 작성 가계부 어플
```

<br>

## 📱 스크린샷
<Blockquote>
실제 앱 구동화면입니다
</Blockquote>

### Machacha

| <img src="./image/login.gif" width="180"/> | <img src="./image/home.gif" width="180"/> | <img src="./image/detail.gif" width="180"/> | <img src="./image/review.gif" width="180"/> | <img src="./image/report.gif" width="180"/> |
|:-:|:-:|:-:|:-:|:-:|
| 로그인 | Home | Detail | 리뷰 | 제보 |
| <img src="./image/search.gif" width="180"/> | <img src="./image/stt.gif" width="180"/> | <img src="./image/register.gif" width="180"/> | <img src="./image/ocr.gif" width="180"/> | <img src="./image/magazine.gif" width="180"/> |
| 검색 | STT | 등록 | OCR | 매거진 |
| <img src="./image/profilEdit.gif" width="180"/> | <img src="./image/setting.gif" width="180"/> ||||
| 프로필 수정 | 설정 |  |  |  |

<br>

## 🏃‍ 기능

<br>

## ⚙️ 개발 환경
<details>
<summary>펼처서 보기</summary>
<div markdown="1">

- iOS 14.0 이상
- xcode 13.0
- iPhone 14 Pro에서 최적화됨
- 가로모드 미지원

</div>
</details>

## ⚒️ 활용한 기술
<details>
<summary>펼처서 보기</summary>
<div markdown="1">



</div>
</details>
<br>

## 🤝 규칙
<details>
<summary>규칙 10가지</summary>
<div markdown="1">

```
1. 존중, 배려(경어), 재미
2. 9-6시 개발하고 야근 지양하기
3. 매일 데일리 스크럼 진행 (am 10:00 ~ am 10:15 15분간)
    ◦ 특강이 있을 경우, 끝난 다음 정각부터 시작
    ◦ 보이스 및 화상 의무
    ◦ 요일마다 진행자 돌아가면서  진행하기
4. PR은 'pm 5:00'과 'am 2:00'에 각자 올리기
    ◦ Reviewer는 보조 기능인 개발자에게 걸기(GeonHyeongKim, suekim999, jwoo820, jeoneeee, Heodoo)
    ◦ Merge는 보조 기능을 역할을 맡은 개발자가 해주기
5. 개발도 중요하지만, 기록도 생각하기
    ◦ Docs Folde 참고
    ◦ Project 카반보드 활용
7. '아!’ & ‘어?’ 참아보기
8. 막힐때, @맨션을 걸어서 Pair 코딩하기
9. 세미나(발표) - 자유주제(요청)
    ◦ Seminar Folder 참고
    ◦ 목(pm 10시)
    ◦ 5~10분 (max 15분)
10. 실제로 오프라인으로 자료 수집하기
```

</div>
</details>

<details>
<summary>코드 컨벤션</summary>
<div markdown="1">

- feat/이슈번호-큰기능명/세부기능명
```
- [Feat] 새로운 기능 구현
- [Chore] 코드 수정, 내부 파일 수정, 주석
- [Add] Feat 이외의 부수적인 코드 추가, 라이브러리 추가, 새로운 파일 생성 시, 에셋 추가
- [Fix] 버그, 오류 해결
- [Del] 쓸모없는 코드 삭제
- [Move] 파일 이름/위치 변경
```

</div>
</details>

<details>
<summary>깃 브렌치</summary>
<div markdown="2">

- feat/이슈번호-큰기능명/세부기능명
```
예시)
feat/13-tab1/map
feat/13-tab1/search
feat/26-tab2/recipe
```

</div>
</details>

<details>
<summary>전체 폴더링 컨벤션</summary>
<div markdown="3">

```
📦 finalproject-machacha
| 
+ 🗂 Seminar      // 매주(3주) 진행한 세미나 자료들
|         
+ 🗂 Docs         // 매일 Daily Scrum 회의록
│         
+ 🗂 src          // Project File
│         
+------🗂 backend         // Firebase cloud function 
|
+------🗂 frontend      
        |
        +------🗂 MachachaAdmin   // Machacha admin Project
        |
        +------🗂 Machacha        // Machacha Project
```
</div>
</details>

<details>
<summary>Machacha 폴더링 컨벤션</summary>
<div markdown="4">

```
📦 Machacha
|
+ 🗂 Settings
|
+------🗂 MachachaPush    // GoogleService-Info, PushConfig
|
+------🗂 Machacha        // GoogleService-Info, Config
|
+ 🗂 Configuration
|         
+------🗂 Constants       // 기기의 제약사항: width, height를 struct로 관리
│         
+------🗂 Extensions      // extension 모음
│         
+------🗂 Fonts           // 폰트 모음: 무료 폰트인 Pretendard 사용
|
+------🗂 Localizable     // 다국어 지원 파일 
|
+------🗂 Modifiers       // View Modifier 모음
|
+------🗂 PreviewDevice   // PreView에서 Deivce 기기 보기
|
+------🗂 SoundEffects    // 소리 Assets
│         
+ 🗂 Sources
|
+------🗂 Services        // Firebase Request Router/Error
|
+------🗂 Models          // Json을 위한 Hashable, Codable, Identifiable 프로토콜을 체택한 struct 관리
│         
+------🗂 ViewModels      // ObservableObject을 체택하여 네트워크 관리
|
+------🗂 Views           // 여러 View를 모음
        |
        +------🗂 Login         // Login
        |
        +------🗂 Splash        // Splash View
        │         
        +------🗂 Home          // Tab 1
        |
        +------🗂 MapSearch     // Tab 2
        |
        +------🗂 Register(+)   // Tab 3
        │         
        +------🗂 Magazine      // Tab 4
        |
        +------🗂 Profile       // Tab 5
        |
        +------🗂 Detail        // Tab 1, 2, 4 -> 가게 상세 View
        |
        +------🗂 ETC.          // 여분의 View: CustomTabView, TextButtonClearButton 등
```
</div>
</details>
<br>


## 라이센스
Machacha is available under the MIT license. See the [LICENSE](https://github.com/APPSCHOOL1-REPO/finalproject-machacha/blob/main/LICENSE) file for more info.

- [Google MLKit](https://developers.google.com/ml-kit/terms) 
- [InstantSearchVoiceOverlay](https://github.com/algolia/voice-overlay-ios)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [FlagKit](https://github.com/madebybowtie/FlagKit)
- [AlertToast](https://github.com/elai950/AlertToast)

