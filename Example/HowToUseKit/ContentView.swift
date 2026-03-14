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

    private static let screenImage = UIImage(named: "screenshot")

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
            tint: .orange,
            hideBezels: false,
            theme: .dark,
            hidesBackButtonOnFirstItem: true,
            items: [
                .init(title: "Welcome to iOS 26",
                      subtitle: "Introducing a new design\nwith Liquid Glass.",
                      screenshot: Self.screenImage),
                .init(title: "Powerful Features",
                      subtitle: "Everything you need,\nbeautifully designed.",
                      screenshot: Self.screenImage),
                .init(title: "Get Started",
                      subtitle: "Tap below to begin your journey.",
                      screenshot: Self.screenImage,
                      zoomScale: 1.3, zoomAnchor: .bottom),
            ],
            onComplete: { dismiss() }
        )
    }
}


// MARK: - Settings Demo

struct SettingsDemo: View {
    @Binding var isSubscribed: Bool

    var subscriptionState: SettingView.Item.SubscriptionState {
        isSubscribed
            ? .subscribed(planTitle: "Lifetime Access", renewalInfo: "Lifetime")
            : .notSubscribed()
    }

    var subscriptionSubtitle: String {
        isSubscribed ? "Active — Lifetime Access" : "Unlock all features"
    }

    var body: some View {
        SettingView(
            tint: .orange,
            theme: .light,
            sections: [
                .init(header: "Subscriptions", items: [
                    .subscription(
                        title: "HowToUseKit Premium",
                        subtitle: subscriptionSubtitle,
                        state: subscriptionState,
                        destination: {
                            PaywallDemo(isSubscribed: $isSubscribed)
                        }
                    )
                ]),
                .init(header: "App Launch", items: [
                    .toggle(icon: "play.circle.fill", iconColor: .blue,
                            title: "Start with last state",
                            isOn: .constant(true)),
                    .toggle(icon: "rectangle.split.2x1", iconColor: .purple,
                            title: "Expandable tab bar",
                            isOn: .constant(false)),
                ]),
                .init(items: [
                    .navigation(
                        icon: "questionmark.circle.fill",
                        iconColor: .gray,
                        title: "How to Use",
                        destination: { OnboardingDemo() }
                    ),
                    .link(icon: "lock.fill", title: "Privacy Policy",
                          url: URL(string: "https://apple.com")!),
                    .link(icon: "doc.text.fill", title: "Terms of Service",
                          url: URL(string: "https://apple.com")!),
                    .link(icon: "envelope.fill", title: "Contact Us",
                          url: URL(string: "mailto:hello@example.com")!,
                          tintColor: .blue),
                ]),
            ],
            footer: .init(developerName: "Developed by OFFSTUDIO")
        )
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
            tint: .orange,
            theme: .dark,
            title: "Unlock Everything",
            subtitle: "Get full access to all features",
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
                .init(rating: 5, text: "Amazing app! Changed how I work every day. 💯"),
                .init(rating: 5, text: "Best purchase I've made this year. Highly recommended!"),
                .init(rating: 5, text: "Thank you for making such a great app. 👏"),
            ],
            features: [
                "Remove Ads",
                "Unlimited Access",
                "All Premium Themes",
                "Priority Support",
                "All Future Premium Features",
            ],
            termsURL: URL(string: "https://apple.com"),
            privacyURL: URL(string: "https://apple.com"),
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
