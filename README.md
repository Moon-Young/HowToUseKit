# HowToUseKit

iOS onboarding and paywall UI components with Liquid Glass design support.

- ✅ iOS 18+ support (iOS 26 Liquid Glass, iOS 18~25 standard UI)
- ✅ Inter font bundled (no setup required)
- ✅ Dark / Light theme
- ✅ `OnBoarding` — first-launch & how-to-use flow
- ✅ `Paywall` — subscription & purchase screen

---

## Installation

**Swift Package Manager**

In Xcode: **File → Add Package Dependencies**

```
https://github.com/Moon-Young/HowToUseKit
```

---

## OnBoarding

### Basic Usage

```swift
import HowToUseKit

// First launch
OnBoarding(
    tint: .blue,
    theme: .dark,
    items: [
        .init(
            title: "Welcome",
            subtitle: "Discover all the features.",
            screenshot: UIImage(named: "screen1")
        ),
        .init(
            title: "Customize",
            subtitle: "Make it yours.",
            screenshot: UIImage(named: "screen2"),
            zoomScale: 1.2,
            zoomAnchor: .top
        ),
    ],
    onComplete: {
        // mark onboarding as seen
    }
)

// Settings / How to Use (with dismiss button)
OnBoarding(
    tint: .blue,
    theme: .dark,
    items: [...],
    onComplete: { dismiss() },
    onDismiss: { dismiss() }   // shows X button when provided
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tint` | `Color` | `.blue` | Continue button color |
| `hideBezels` | `Bool` | `false` | Hide device frame around screenshot |
| `screenshotCornerRadius` | `CGFloat` | `70` | Corner radius of the screenshot |
| `theme` | `Theme` | `.dark` | `.dark` or `.light` |
| `hidesBackButtonOnFirstItem` | `Bool` | `true` | Hide back button on first page |
| `continueTitle` | `String` | `"Continue"` | Label for the next button |
| `getStartedTitle` | `String` | `"Get Started"` | Label for the last button |
| `items` | `[Item]` | — | Pages |
| `onComplete` | `() -> Void` | — | Called when last button is tapped |
| `onDismiss` | `(() -> Void)?` | `nil` | Shows X button when provided |

### Item Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | — | Page title |
| `subtitle` | `String` | — | Page subtitle |
| `screenshot` | `UIImage?` | `nil` | Device screenshot image |
| `zoomScale` | `CGFloat` | `1` | Zoom scale applied to screenshot |
| `zoomAnchor` | `UnitPoint` | `.center` | Zoom anchor (`.top`, `.center`, `.bottom`) |

---

## Paywall

### Basic Usage

```swift
import HowToUseKit

Paywall(
    tint: .blue,
    theme: .dark,
    title: "Unlock Premium",
    subtitle: "No ads. Full access.",
    plans: [
        .init(
            id: "lifetime",
            price: "$29.99",
            title: "Lifetime Access",
            isBest: true,
            savePercent: 40,
            purchaseButtonTitle: "Purchase Lifetime Access"
        ),
        .init(
            id: "yearly",
            price: "$9.99",
            title: "Yearly",
            purchaseButtonTitle: "Subscribe Yearly"
        ),
        .init(
            id: "monthly",
            price: "$1.99",
            title: "Monthly",
            purchaseButtonTitle: "Subscribe Monthly"
        ),
    ],
    features: [
        "Remove All Ads",
        "Home Screen Widgets",
        "Priority Support",
    ],
    onPurchase: { plan in
        // StoreKit purchase with plan.id
    },
    onRestore: {
        // restore purchases
    },
    onDismiss: { dismiss() }
)
```

### Subscribed State

```swift
Paywall(
    ...
    state: .subscribed(
        planTitle: "Lifetime Access",
        renewalInfo: "Never expires"
    ),
    onPurchase: { _ in },
    onRestore: { /* manage subscription */ }
)
```

### With Reviews & Legal Links

```swift
Paywall(
    ...
    notice: "Cancel anytime",
    reviews: [
        .init(rating: 5, text: "Best app I've used!"),
        .init(rating: 5, text: "Worth every penny."),
    ],
    features: ["Remove Ads", "Unlock All Features"],
    termsURL: URL(string: "https://yoursite.com/terms"),
    privacyURL: URL(string: "https://yoursite.com/privacy"),
    ...
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tint` | `Color` | `.blue` | Button and accent color |
| `theme` | `Theme` | `.dark` | `.dark` or `.light` |
| `appIcon` | `UIImage?` | `nil` | App icon shown at top |
| `title` | `String` | — | Main title |
| `subtitle` | `String?` | `nil` | Subtitle below title |
| `plans` | `[Plan]` | — | Subscription plan options |
| `defaultSelectedIndex` | `Int` | `0` | Initially selected plan index |
| `notice` | `String?` | `nil` | Small notice text below plans |
| `reviews` | `[Review]` | `[]` | User review cards |
| `features` | `[String]` | `[]` | Feature list with checkmarks |
| `termsURL` | `URL?` | `nil` | Terms of Service link |
| `privacyURL` | `URL?` | `nil` | Privacy Policy link |
| `state` | `SubscriptionState` | `.notSubscribed` | Current subscription state |
| `onPurchase` | `(Plan) -> Void` | — | Called with selected plan |
| `onRestore` | `() -> Void` | — | Called on restore tap |
| `onDismiss` | `(() -> Void)?` | `nil` | Shows X button when provided |

### Plan Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `String` | — | StoreKit product ID |
| `price` | `String` | — | Display price string (e.g. `"$9.99"`) |
| `title` | `String` | — | Plan label (e.g. `"Yearly"`) |
| `isBest` | `Bool` | `false` | Shows "BEST" badge |
| `savePercent` | `Int?` | `nil` | Shows "SAVE X%" badge |
| `purchaseButtonTitle` | `String` | — | Purchase button label |

---

## Theme

Both `OnBoarding` and `Paywall` share `OnBoarding.Theme`:

```swift
.dark   // white text, dark background
.light  // system label colors, light background
```
