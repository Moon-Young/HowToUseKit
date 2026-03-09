# HowToUseKit

iOS onboarding UI component with Liquid Glass design support.

- ✅ iOS 18+ support (iOS 26 Liquid Glass, iOS 18~25 standard UI)
- ✅ Inter font bundled (no setup required)
- ✅ Dark / Light theme
- ✅ Supports both first-launch and settings flows

---

## Installation

**Swift Package Manager**

```
https://github.com/your-username/HowToUseKit
```

---

## Usage

### First Launch (onboarding)

```swift
import HowToUseKit

OnBoarding(
    tint: .blue,
    theme: .dark,
    continueTitle: "계속",
    getStartedTitle: "시작하기",
    items: [
        .init(title: "Welcome", subtitle: "Discover features.", screenshot: UIImage(named: "screen1")),
        .init(title: "Customize", subtitle: "Make it yours.", screenshot: UIImage(named: "screen2")),
    ],
    onComplete: {
        // 온보딩 완료 처리
    }
)
```

### Settings Flow (always shows dismiss button)

```swift
OnBoarding(
    tint: .orange,
    theme: .light,
    hidesBackButtonOnFirstItem: false,
    continueTitle: "다음",
    getStartedTitle: "닫기",
    items: [...],
    onComplete: {
        dismiss()
    },
    onDismiss: {
        dismiss()
    }
)
```

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tint` | `Color` | `.blue` | Continue 버튼 색상 |
| `hideBezels` | `Bool` | `false` | 디바이스 프레임 숨김 |
| `screenshotCornerRadius` | `CGFloat` | `70` | 스크린샷 코너 반경 |
| `theme` | `Theme` | `.dark` | 다크/라이트 테마 |
| `hidesBackButtonOnFirstItem` | `Bool` | `true` | 첫 페이지 뒤로가기 숨김 |
| `continueTitle` | `String` | `"Continue"` | 다음 버튼 텍스트 |
| `getStartedTitle` | `String` | `"Get Started"` | 마지막 버튼 텍스트 |
| `items` | `[Item]` | — | 온보딩 페이지 목록 |
| `onComplete` | `() -> Void` | — | 완료 콜백 |
| `onDismiss` | `(() -> Void)?` | `nil` | 닫기 버튼 콜백 (nil이면 버튼 숨김) |
