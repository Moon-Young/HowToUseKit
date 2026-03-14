//
//  Paywall.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/14/26.
//

import SwiftUI
import UIKit

// MARK: - Paywall

@MainActor
public struct Paywall: View {
    public var tint: Color
    public var theme: OnBoarding.Theme
    public var appIcon: UIImage?
    public var title: String
    public var subtitle: String?
    public var plans: [Plan]
    public var defaultSelectedIndex: Int
    public var notice: String?
    public var reviews: [Review]
    public var features: [String]
    public var termsURL: URL?
    public var privacyURL: URL?
    public var state: SubscriptionState
    public var onPurchase: (Plan) -> Void
    public var onRestore: () -> Void
    public var onDismiss: (() -> Void)?

    @State private var selectedIndex: Int

    public init(
        tint: Color = .blue,
        theme: OnBoarding.Theme = .dark,
        appIcon: UIImage? = nil,
        title: String,
        subtitle: String? = nil,
        plans: [Plan],
        defaultSelectedIndex: Int = 0,
        notice: String? = nil,
        reviews: [Review] = [],
        features: [String] = [],
        termsURL: URL? = nil,
        privacyURL: URL? = nil,
        state: SubscriptionState = .notSubscribed,
        onPurchase: @escaping (Plan) -> Void,
        onRestore: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.tint = tint
        self.theme = theme
        self.appIcon = appIcon
        self.title = title
        self.subtitle = subtitle
        self.plans = plans
        self.defaultSelectedIndex = defaultSelectedIndex
        self.notice = notice
        self.reviews = reviews
        self.features = features
        self.termsURL = termsURL
        self.privacyURL = privacyURL
        self.state = state
        self.onPurchase = onPurchase
        self.onRestore = onRestore
        self.onDismiss = onDismiss
        self._selectedIndex = State(initialValue: defaultSelectedIndex)
        _ = registerFontsOnce
    }

    public var body: some View {
        ZStack(alignment: .top) {
            theme.paywallBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // App Icon
                    if let appIcon {
                        Image(uiImage: appIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.top, 56)
                            .padding(.bottom, 20)
                    } else {
                        Spacer().frame(height: 56)
                    }

                    // Title & Subtitle
                    Text(title)
                        .font(.custom("Inter18pt-Bold", size: 24))
                        .foregroundStyle(theme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    if let subtitle {
                        Text(subtitle)
                            .font(.custom("Inter18pt-Regular", size: 16))
                            .foregroundStyle(theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 6)
                    }

                    // Content by state
                    switch state {
                    case .notSubscribed:
                        PurchaseContent()
                    case let .subscribed(planTitle, renewalInfo):
                        SubscribedContent(planTitle: planTitle, renewalInfo: renewalInfo)
                    }
                }
                .padding(.bottom, 140) // space for bottom buttons
            }

            // Bottom Buttons (floating)
            VStack(spacing: 0) {
                Spacer()
                BottomButtonsView()
            }
            .ignoresSafeArea(edges: .bottom)

            // Dismiss Button
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(theme.secondaryText)
                        .frame(width: 28, height: 28)
                        .background(theme.closeButtonBackground, in: Circle())
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 12)
                .padding(.trailing, 16)
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }


    // MARK: - Purchase Content (not subscribed)

    @ViewBuilder
    func PurchaseContent() -> some View {
        // Plans
        VStack(spacing: 10) {
            ForEach(plans.indices, id: \.self) { index in
                PlanCard(plan: plans[index], isSelected: selectedIndex == index)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedIndex = index
                        }
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)

        // Notice
        if let notice {
            Text(notice)
                .font(.custom("Inter18pt-Regular", size: 14))
                .foregroundStyle(theme.secondaryText)
                .padding(.top, 12)
        }

        // Reviews
        if !reviews.isEmpty {
            ReviewsSection()
                .padding(.top, 32)
        }

        // Features
        if !features.isEmpty {
            FeaturesSection()
                .padding(.top, 28)
        }

        // Terms & Privacy
        if termsURL != nil || privacyURL != nil {
            LegalLinksView()
                .padding(.top, 20)
        }
    }


    // MARK: - Subscribed Content

    @ViewBuilder
    func SubscribedContent(planTitle: String, renewalInfo: String?) -> some View {
        // Active badge
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(tint)
                .padding(.top, 32)

            Text("You're subscribed!")
                .font(.custom("Inter18pt-Bold", size: 22))
                .foregroundStyle(theme.primaryText)

            VStack(spacing: 4) {
                Text(planTitle)
                    .font(.custom("Inter18pt-SemiBold", size: 17))
                    .foregroundStyle(theme.primaryText)
                if let renewalInfo {
                    Text(renewalInfo)
                        .font(.custom("Inter18pt-Regular", size: 14))
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(theme.planCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 20)
        }

        // Features
        if !features.isEmpty {
            FeaturesSection()
                .padding(.top, 28)
        }

        // Terms & Privacy
        if termsURL != nil || privacyURL != nil {
            LegalLinksView()
                .padding(.top, 20)
        }
    }


    // MARK: - Plan Card

    @ViewBuilder
    func PlanCard(plan: Plan, isSelected: Bool) -> some View {
        HStack(spacing: 14) {
            // Radio
            ZStack {
                Circle()
                    .stroke(isSelected ? tint : theme.secondaryText.opacity(0.4), lineWidth: 2)
                    .frame(width: 22, height: 22)
                if isSelected {
                    Circle()
                        .fill(tint)
                        .frame(width: 12, height: 12)
                }
            }

            // Price & title
            VStack(alignment: .leading, spacing: 3) {
                Text(plan.price)
                    .font(.custom("Inter18pt-Bold", size: 18))
                    .foregroundStyle(theme.primaryText)
                Text(plan.title)
                    .font(.custom("Inter18pt-Regular", size: 14))
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            // Badges
            HStack(spacing: 6) {
                if let save = plan.savePercent {
                    Text("SAVE \(save)%")
                        .font(.custom("Inter18pt-Bold", size: 11))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green, in: Capsule())
                }
                if plan.isBest {
                    Text("BEST")
                        .font(.custom("Inter18pt-Bold", size: 11))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(tint, in: Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(theme.planCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? tint : Color.clear, lineWidth: 2)
        }
    }


    // MARK: - Reviews Section

    @ViewBuilder
    func ReviewsSection() -> some View {
        VStack(spacing: 20) {
            ForEach(Array(reviews.enumerated()), id: \.offset) { _, review in
                ReviewCard(review: review)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    func ReviewCard(review: Review) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i < review.rating ? "star.fill" : "star")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.yellow)
                }
            }
            Text(review.text)
                .font(.custom("Inter18pt-Regular", size: 15))
                .foregroundStyle(theme.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(theme.planCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }


    // MARK: - Features Section

    @ViewBuilder
    func FeaturesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(features, id: \.self) { feature in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 20)
                    Text(feature)
                        .font(.custom("Inter18pt-Regular", size: 16))
                        .foregroundStyle(theme.primaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
    }


    // MARK: - Legal Links

    @ViewBuilder
    func LegalLinksView() -> some View {
        HStack(spacing: 12) {
            if let termsURL {
                Link("Terms of Service", destination: termsURL)
                    .font(.custom("Inter18pt-Regular", size: 13))
                    .foregroundStyle(theme.secondaryText)
                    .underline()
            }
            if termsURL != nil && privacyURL != nil {
                Text("/")
                    .font(.custom("Inter18pt-Regular", size: 13))
                    .foregroundStyle(theme.secondaryText)
            }
            if let privacyURL {
                Link("Privacy Policy", destination: privacyURL)
                    .font(.custom("Inter18pt-Regular", size: 13))
                    .foregroundStyle(theme.secondaryText)
                    .underline()
            }
        }
    }


    // MARK: - Bottom Buttons

    @ViewBuilder
    func BottomButtonsView() -> some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [theme.paywallBackground.opacity(0), theme.paywallBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 32)

            VStack(spacing: 12) {
                switch state {
                case .notSubscribed:
                    let selectedPlan = plans.indices.contains(selectedIndex) ? plans[selectedIndex] : nil
                    Button {
                        if let plan = selectedPlan {
                            onPurchase(plan)
                        }
                    } label: {
                        Text(selectedPlan?.purchaseButtonTitle ?? "Subscribe")
                            .font(.custom("Inter18pt-Bold", size: 17))
                            .foregroundStyle(tint.contrastText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(tint, in: Capsule())
                    }
                    .padding(.horizontal, 20)

                    Button(action: onRestore) {
                        Text("Restore Purchases")
                            .font(.custom("Inter18pt-Regular", size: 14))
                            .foregroundStyle(theme.secondaryText)
                            .underline()
                    }

                case .subscribed:
                    Button(action: onRestore) {
                        Text("Manage Subscription")
                            .font(.custom("Inter18pt-SemiBold", size: 17))
                            .foregroundStyle(tint)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(tint.opacity(0.12), in: Capsule())
                    }
                    .padding(.horizontal, 20)

                    Button(action: onRestore) {
                        Text("Restore Purchases")
                            .font(.custom("Inter18pt-Regular", size: 14))
                            .foregroundStyle(theme.secondaryText)
                            .underline()
                    }
                }
            }
            .padding(.bottom, 36)
            .background(theme.paywallBackground)
        }
    }
}


// MARK: - Plan

extension Paywall {
    public struct Plan: Identifiable, Sendable {
        public var id: String
        public var price: String
        public var title: String
        public var isBest: Bool
        public var savePercent: Int?
        public var purchaseButtonTitle: String

        public init(
            id: String,
            price: String,
            title: String,
            isBest: Bool = false,
            savePercent: Int? = nil,
            purchaseButtonTitle: String
        ) {
            self.id = id
            self.price = price
            self.title = title
            self.isBest = isBest
            self.savePercent = savePercent
            self.purchaseButtonTitle = purchaseButtonTitle
        }
    }
}


// MARK: - Review

extension Paywall {
    public struct Review: Sendable {
        public var rating: Int
        public var text: String

        public init(rating: Int, text: String) {
            self.rating = max(1, min(5, rating))
            self.text = text
        }
    }
}


// MARK: - SubscriptionState

extension Paywall {
    public enum SubscriptionState: Sendable {
        case notSubscribed
        case subscribed(planTitle: String, renewalInfo: String? = nil)
    }
}


// MARK: - Theme Extension

extension OnBoarding.Theme {
    var paywallBackground: Color {
        switch self {
        case .dark: return Color(red: 0.06, green: 0.06, blue: 0.06)
        case .light: return Color(red: 0.97, green: 0.97, blue: 0.97)
        }
    }

    var planCardBackground: Color {
        switch self {
        case .dark: return Color(red: 0.13, green: 0.13, blue: 0.13)
        case .light: return Color.white
        }
    }

    var closeButtonBackground: Color {
        switch self {
        case .dark: return Color(white: 1, opacity: 0.15)
        case .light: return Color(white: 0, opacity: 0.08)
        }
    }
}


// MARK: - Color Contrast Helper

private extension Color {
    var contrastText: Color {
        // Simple luminance check — white on dark tint, black on light tint
        .white
    }
}
