//
//  ContentView.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/6/26.
//

import SwiftUI
import HowToUseKit

struct ContentView: View {
    @State private var showOnboarding = true
    @State private var showSettings = false
    @State private var isSubscribed = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 20) {
                Button("Show Onboarding") { showOnboarding = true }
                    .buttonStyle(.borderedProminent)
                Button("Show Settings") { showSettings = true }
                    .buttonStyle(.borderedProminent)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingDemo()
        }
        .sheet(isPresented: $showSettings) {
            SettingsDemo(isSubscribed: $isSubscribed)
        }
    }
}


// MARK: - Onboarding Demo

struct OnboardingDemo: View {
    @Environment(\.dismiss) private var dismiss
    private static let screenImage = UIImage(named: "screenshot")

    var body: some View {
        OnBoarding(
            tint: .blue,
            hideBezels: false,
            theme: .dark,
            hidesBackButtonOnFirstItem: true,
            continueTitle: "Next",
            getStartedTitle: "Let's Go",
            items: [
                .init(
                    title: "Welcome to SECalendar",
                    subtitle: "Works perfectly with your iOS Calendar.\nClean, fast, and beautiful.",
                    screenshot: Self.screenImage
                ),
                .init(
                    title: "Every Schedule at a Glance",
                    subtitle: "Switch between monthly, weekly,\nand daily views the way you like it.",
                    screenshot: Self.screenImage,
                    zoomScale: 1.15,
                    zoomAnchor: .top
                ),
                .init(
                    title: "Add Events in a Tap",
                    subtitle: "Tap any date to instantly\nadd a new event.",
                    screenshot: Self.screenImage,
                    zoomScale: 1.3,
                    zoomAnchor: .bottom
                ),
                .init(
                    title: "Widgets on Your Home Screen",
                    subtitle: "Keep today's schedule visible\nright from your home screen.",
                    screenshot: Self.screenImage,
                    zoomScale: 1.2,
                    zoomAnchor: .center
                ),
                .init(
                    title: "Smart Notifications",
                    subtitle: "Get reminded at the right time\nwith customizable alerts.",
                    screenshot: Self.screenImage,
                    zoomScale: 1.1,
                    zoomAnchor: .top
                ),
                .init(
                    title: "You're All Set!",
                    subtitle: "Start organizing your life\nwith SECalendar.",
                    screenshot: Self.screenImage
                ),
            ],
            onComplete: { dismiss() },
            onDismiss: { dismiss() }
        )
    }
}


// MARK: - Settings Demo

struct SettingsDemo: View {
    @Binding var isSubscribed: Bool

    @State private var startWithLast = true
    @State private var expandableTab = true
    @State private var multiSelect = false
    @State private var useAppNotif = false
    @State private var showHowToUse = false

    var subscriptionState: SettingView.Item.SubscriptionState {
        isSubscribed
            ? .subscribed(planTitle: "Lifetime Access", renewalInfo: "Lifetime — never expires")
            : .notSubscribed()
    }

    var subscriptionSubtitle: String {
        isSubscribed ? "All features unlocked" : "No ads, widgets, and more"
    }

    var body: some View {
        SettingView(
            tint: .blue,
            theme: .light,
            sections: [

                // MARK: App Launch
                .init(header: "App Launch", items: [
                    .toggle(
                        icon: "clock.arrow.circlepath", iconColor: .blue,
                        title: "Start with last selected sheet",
                        isOn: $startWithLast,
                        contextMenu: [
                            .init(title: "Reset to Default", systemImage: "arrow.uturn.left") {
                                startWithLast = true
                            }
                        ]
                    ),
                    .toggle(
                        icon: "rectangle.expand.vertical", iconColor: .purple,
                        title: "Expandable sheet tab bar",
                        isOn: $expandableTab
                    ),
                    .toggle(
                        icon: "checklist", iconColor: .orange,
                        title: "Multi-select sheet tab bar",
                        isOn: $multiSelect
                    ),
                ]),

                // MARK: Notifications
                .init(
                    header: "Notifications",
                    footer: useAppNotif
                        ? "App notification mode only applies to events added in this app. Existing calendar alerts continue via the default Calendar app."
                        : "Default Calendar mode delivers all event alerts through the iOS Calendar app.",
                    items: [
                        .custom {
                            NotificationStatusBanner(useAppNotif: useAppNotif)
                        },
                        .toggle(
                            icon: "bell.fill", iconColor: .red,
                            title: "Use SECalendar Notifications",
                            subtitle: useAppNotif
                                ? "Tap to switch to default Calendar alerts"
                                : "Tap to enable in-app notifications",
                            isOn: $useAppNotif
                        ),
                    ]
                ),

                // MARK: My Calendars
                .init(header: "My Calendars", items: [
                    .custom {
                        CalendarListPreview()
                    },
                ]),

                // MARK: Permissions
                .init(header: "Permissions", items: [
                    .permission(
                        icon: "calendar",
                        iconColor: .blue,
                        title: "Calendar Access",
                        subtitle: "You can access all calendar data.",
                        status: .granted
                    ),
                    .permission(
                        icon: "bell.fill",
                        iconColor: .red,
                        title: "Notification Permission",
                        subtitle: "Please allow notifications in Settings.",
                        status: .denied,
                        action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    ),
                ]),

                // MARK: Subscriptions
                .init(header: "Subscriptions", items: [
                    .subscription(
                        icon: "crown.fill",
                        iconColor: .orange,
                        title: "SECalendar Premium",
                        subtitle: subscriptionSubtitle,
                        state: subscriptionState,
                        destination: {
                            PaywallDemo(isSubscribed: $isSubscribed)
                        }
                    ),
                ]),

                // MARK: Support
                .init(items: [
                    .action(
                        icon: "questionmark.circle.fill",
                        title: "How to Use",
                        action: { showHowToUse = true }
                    ),
                    .link(
                        icon: "lock.fill",
                        title: "Privacy Policy",
                        url: URL(string: "https://offstudio.notion.site/Privacy-Policy-OFFSTUDIO-1b95f84ba94780a387fad4e59d9bb139?pvs=74")!
                    ),
                    .link(
                        icon: "doc.text.fill",
                        title: "Terms of Service",
                        url: URL(string: "https://offstudio.notion.site/Terms-of-Use-OFFSTUDIO-1b95f84ba94780569654ee08852cec9e?pvs=74")!
                    ),
                    .action(
                        icon: "envelope.fill",
                        title: "Contact Us",
                        tintColor: .blue,
                        action: { sendSupportEmail() }
                    ),
                ]),
            ],
            footer: .init(
                appIcon: UIImage(named: "AppIcon"),
                developerName: "Developed by OFFSTUDIO"
            )
        )
        .fullScreenCover(isPresented: $showHowToUse) {
            OnboardingDemo()
        }
    }

    // MARK: - Contact Us Email

    private func sendSupportEmail() {
        let email = "offstudioapp@gmail.com"
        let subject = "SECalendar App Support"

        let device = UIDevice.current
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        let userStatus = isSubscribed ? "Premium User" : "Free User"

        let body = """


        [Please describe your inquiry here]


        -------------------------------------------
        Device Info for Developer Support:
        Device: \(device.modelName)
        OS: \(device.systemName) \(device.systemVersion)
        App Version: \(appVersion) (\(buildNumber))
        User Status: \(userStatus)
        -------------------------------------------
        """

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}


// MARK: - Notification Status Banner (Custom Item)

struct NotificationStatusBanner: View {
    let useAppNotif: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: useAppNotif ? "app.badge.fill" : "calendar.badge.clock")
                .font(.title2)
                .foregroundStyle(useAppNotif ? Color.red : Color.blue)
                .frame(width: 32)
                .contentTransition(.symbolEffect(.replace))

            VStack(alignment: .leading, spacing: 4) {
                Text(useAppNotif ? "Using App Notifications" : "Using Default Calendar Alerts")
                    .font(.subheadline.bold())
                    .contentTransition(.numericText())
                Text(useAppNotif
                     ? "New event alerts will be sent from SECalendar."
                     : "Event alerts are delivered via the iOS Calendar app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.25), value: useAppNotif)
    }
}


// MARK: - Calendar List Preview (Custom Item)

struct CalendarListPreview: View {
    @State private var hiddenIndices: Set<Int> = []

    private let calendars: [(name: String, color: Color)] = [
        ("Personal", .blue),
        ("Work", .orange),
        ("Family", .green),
        ("Fitness", .red),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(calendars.enumerated()), id: \.offset) { index, cal in
                HStack(spacing: 12) {
                    Circle()
                        .fill(cal.color)
                        .frame(width: 12, height: 12)
                        .opacity(hiddenIndices.contains(index) ? 0.35 : 1)

                    Text(cal.name)
                        .font(.system(size: 16))
                        .foregroundStyle(hiddenIndices.contains(index) ? .secondary : .primary)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if hiddenIndices.contains(index) {
                                hiddenIndices.remove(index)
                            } else {
                                hiddenIndices.insert(index)
                            }
                        }
                    } label: {
                        Image(systemName: hiddenIndices.contains(index) ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 15))
                    }
                    .buttonStyle(.borderless)
                    .padding(.trailing, 4)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 10)

                if index < calendars.count - 1 {
                    Divider()
                }
            }

            Divider()

            Button {
            } label: {
                Label("Add Calendar", systemImage: "plus.circle.fill")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Paywall Demo

struct PaywallDemo: View {
    @Binding var isSubscribed: Bool
    @Environment(\.dismiss) private var dismiss

    var paywallState: Paywall.SubscriptionState {
        isSubscribed
            ? .subscribed(planTitle: "Lifetime Access", renewalInfo: "Lifetime — never expires")
            : .notSubscribed
    }

    var body: some View {
        Paywall(
            tint: .blue,
            theme: .dark,
            title: "Unlock SECalendar",
            subtitle: "No ads. Widgets. Full access.",
            plans: [
                .init(id: "lifetime", price: "₩44,000", title: "Lifetime Access",
                      isBest: true, savePercent: 30,
                      purchaseButtonTitle: "Purchase Lifetime Access"),
                .init(id: "yearly", price: "₩28,900", title: "Subscribe for a Year",
                      purchaseButtonTitle: "Purchase Yearly Subscription"),
                .init(id: "monthly", price: "₩3,300", title: "Subscribe for a Month",
                      purchaseButtonTitle: "Purchase Monthly Subscription"),
            ],
            defaultSelectedIndex: 0,
            notice: "Cancel Anytime",
            reviews: [
                .init(rating: 5, text: "Best calendar app I've used. Worth every penny! 🙌"),
                .init(rating: 5, text: "Clean UI, no nonsense. Premium is a no-brainer."),
                .init(rating: 5, text: "Widgets are amazing. Changed how I plan my day."),
            ],
            features: [
                "Remove All Ads",
                "Home Screen Widgets",
                "Unlimited Calendars",
                "Priority Support",
                "All Future Premium Features",
            ],
            termsURL: URL(string: "https://offstudio.notion.site/Terms-of-Use-OFFSTUDIO-1b95f84ba94780569654ee08852cec9e"),
            privacyURL: URL(string: "https://offstudio.notion.site/Privacy-Policy-OFFSTUDIO-1b95f84ba94780a387fad4e59d9bb139"),
            state: paywallState,
            onPurchase: { plan in
                print("Purchase: \(plan.id)")
                isSubscribed = true
                dismiss()
            },
            onRestore: {
                print("Restore tapped")
            },
            onDismiss: { dismiss() }
        )
    }
}


#Preview {
    ContentView()
}
