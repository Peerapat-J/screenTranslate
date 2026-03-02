# ScreenTranslate 사용자 분석 시스템 설계

> 작성일: 2026-03-03

## 목표

- **다운로드 수** 파악 (웹사이트)
- **활성 사용자 수** 파악 (앱)
- 프라이버시 중심 원칙 유지 (개인 식별 불가, 최소 데이터 수집)

## 아키텍처

```
웹사이트 방문 (GA4)
  → DMG 다운로드 클릭 (GA4 이벤트: download_dmg)
    → 앱 실행 (TelemetryDeck: appLaunched)
    → 번역 사용 (TelemetryDeck: translationCompleted)
```

| 영역 | 도구 | 역할 |
|------|------|------|
| 웹사이트 | Google Analytics 4 (G-ZFZX7HR200) | 방문자 수, 다운로드 클릭 수 |
| 앱 | TelemetryDeck Swift SDK | 활성 사용자 수 (DAU/MAU), 기능 사용률 |

## 1. 웹사이트 — GA4 다운로드 이벤트

### 현재 상태
- GA4 기본 설치 완료 (페이지 조회, 스크롤, 이탈 클릭 자동 수집)
- 다운로드 버튼 클릭 이벤트 미설정

### 추가 작업
`index.html`의 다운로드 버튼(Hero, Download 섹션)에 클릭 이벤트 추가:

```js
gtag('event', 'download_dmg', {
  event_category: 'engagement',
  event_label: 'hero'  // 또는 'download_section'
});
```

### 추적 이벤트

| 이벤트명 | 트리거 | 라벨 |
|----------|--------|------|
| `download_dmg` | Hero 다운로드 버튼 클릭 | `hero` |
| `download_dmg` | Download 섹션 버튼 클릭 | `download_section` |

## 2. 앱 — TelemetryDeck

### 선택 이유
- Swift 네이티브 SDK (SPM 지원)
- 프라이버시 중심 설계: IP 저장 안 함, 개인 식별 불가
- Apple App Privacy 정책 준수
- 무료 티어: 월 100,000 시그널 (소규모 앱에 충분)
- 대시보드 제공: DAU, MAU, 앱 버전 분포, OS 버전 등

### SDK 통합

**의존성 추가** (SPM):
```
https://github.com/TelemetryDeck/SwiftSDK
```

**초기화** — `ScreenTranslateApp.swift`:
```swift
import TelemetryDeck

@main
struct ScreenTranslateApp: App {
    init() {
        let config = TelemetryDeck.Config(appID: "<APP_ID>")
        TelemetryDeck.initialize(config: config)
    }
}
```

### 수집 시그널

| 시그널명 | 시점 | 구현 위치 | 목적 |
|----------|------|-----------|------|
| `appLaunched` | 앱 실행 시 | `ScreenTranslateApp.init()` | DAU/MAU 산출 |
| `translationCompleted` | 번역 성공 시 | `AppOrchestrator.processCapture()` | 기능 사용률 |

### 자동 수집 메타데이터 (SDK 기본 제공)
- 앱 버전 (CFBundleShortVersionString)
- 빌드 번호
- macOS 버전
- 기기 아키텍처 (Apple Silicon / Intel)
- 시스템 언어/지역
- 고유 사용자 해시 (역추적 불가, 익명)

### 수집하지 않는 것
- 번역 텍스트 내용
- 언어 쌍 정보
- 스크린 캡처 데이터
- IP 주소
- 개인 식별 정보

## 3. 사전 준비

### TelemetryDeck 계정 설정
1. https://dashboard.telemetrydeck.com 가입
2. 새 앱 생성 → App ID 복사
3. App ID를 코드에 설정 (공개 키 — 시크릿 관리 불필요)

### 대시보드에서 확인 가능한 지표
- **DAU / MAU**: 일일/월간 활성 사용자
- **앱 버전 분포**: 어떤 버전을 많이 쓰는지
- **OS 버전 분포**: macOS 15 vs 16 등
- **기능 사용률**: 번역 횟수 추이

## 4. 구현 범위 요약

| 작업 | 파일 | 난이도 |
|------|------|--------|
| GA4 다운로드 이벤트 추가 | `website/index.html` | 낮음 |
| TelemetryDeck SPM 추가 | `ScreenTranslate.xcodeproj` | 낮음 |
| SDK 초기화 + appLaunched | `ScreenTranslateApp.swift` | 낮음 |
| translationCompleted 시그널 | `AppOrchestrator.swift` | 낮음 |

총 4개 파일 수정, 각각 수 줄 수준의 변경.
