//
//  OnBoarding.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/6/26.
//

import SwiftUI
import UIKit

struct OnBoarding: View {
    var tint: Color = .blue
    var hideBezels: Bool = false
    var screenshotCornerRadius: CGFloat = 70
    var theme: Theme = .dark
    var hidesBackButtonOnFirstItem: Bool = true
    var items: [Item]
    var onComplete: () -> Void
    /// View Properties
    @State private var currentIndex: Int = 0
    @State private var screenshotSize: CGSize = .zero

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            ZStack(alignment: .bottom) {

                ScreenshotView()
                    .compositingGroup()
                    .scaleEffect(
                        items[currentIndex].zoomScale,
                        anchor: items[currentIndex].zoomAnchor)
                    .padding(.top, 35)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 220)

                VStack(spacing: 10) {
                    TextContentView()
                    IndicatorView()
                    ContinueButton()
                }
                .padding(.top, 20)
                .padding(.horizontal, 15)
                .frame(height: 210)
                .background {
                    VariableGlassBlur(18)
                }
                BackButton()

            }
            .preferredColorScheme(theme.colorScheme)
        }
    }



    /// Screenshot View
    @ViewBuilder
    func ScreenshotView() -> some View {
        let shape = ConcentricRectangle(corners: .concentric, isUniform: true)
        GeometryReader {
            let size = $0.size

            Rectangle()
                .fill(theme.screenshotBackground)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(items.indices, id: \.self) { index in

                        let item = items[index]

                        Group {
                            if let screenshot = item.screenshot {
                                Image(uiImage: screenshot)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .onGeometryChange(for: CGSize.self) {
                                        $0.size
                                    } action: { newValue in
                                        if index == 0 {
                                            screenshotSize = newValue
                                        }
                                    }
                                    .clipShape(shape)

                            } else {
                                Rectangle()
                                    .fill(theme.screenshotBackground)
                            }
                        }
                        .frame(width: size.width, height: size.height)

                    }
                }
                .scrollTargetLayout()
            }
            .scrollDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: .init(get: {
                return currentIndex
            }, set: { _ in

            }))
        }
        .clipShape(shape)
        .overlay {
            if screenshotSize != .zero && !hideBezels {
                /// Device Frame UI
                ZStack {
                    shape
                        .stroke(theme.bezelOuter, lineWidth: 6)
                    shape
                        .stroke(theme.bezelInner, lineWidth: 2)
                    shape
                        .stroke(theme.bezelInner, lineWidth: 6)
                        .padding(4)
                }
                .padding(-6)
            }
        }

        .frame(
            maxWidth: screenshotSize.width == 0 ? nil : screenshotSize.width,
            maxHeight: screenshotSize.height == 0 ? nil : screenshotSize.height
        )
        .containerShape(RoundedRectangle(cornerRadius: deviceCornerRadius))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }



    /// Text Content View
    @ViewBuilder
    func TextContentView() -> some View {
        GeometryReader {
            let size = $0.size

            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        let isActive = currentIndex == index

                        VStack(spacing: 6) {
                            Text(item.title)
                                .font(.custom("Inter18pt-SemiBold", size: 20))
                                .lineLimit(1)
                                .foregroundStyle(theme.primaryText)

                            Text(item.subtitle)
                                .font(.custom("Inter18pt-Regular", size: 15))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(theme.secondaryText)
                        }
                        .frame(width: size.width)
                        .compositingGroup()
                        /// Only The current Item is visible others are blurred out!
                        .blur(radius: isActive ? 0 : 30)
                        .opacity(isActive ? 1 : 0)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(true)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: .init(get: {
                return currentIndex as Int?
            }, set: { _ in }))
        }
    }


    /// Indicator View
    @ViewBuilder
    func IndicatorView() -> some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                let isActive: Bool = currentIndex == index

                Capsule()
                    .fill(theme.primaryText.opacity(isActive ? 1 : 0.4))
                    .frame(width: isActive ? 25 : 6, height: 6)
            }
        }
    }

    /// Bottom Continue Button
    @ViewBuilder
    func ContinueButton() -> some View {
        Button {
            if currentIndex == items.count - 1 {
                onComplete()
            } else {
                withAnimation(animation) {
                    currentIndex += 1
                }
            }
        } label: {
            Text(currentIndex == items.count - 1 ? "Get Started" : "Continue")
                .font(.custom("Inter18pt-Medium", size: 17))
                .contentTransition(.numericText())
                .padding(.vertical, 6)
        }
        .tint(tint)
        .buttonStyle(.glassProminent)
        .buttonSizing(.flexible)
        .padding(.horizontal, 30)
    }

    /// Back Button
    @ViewBuilder
    func BackButton() -> some View {
        let isHidden = hidesBackButtonOnFirstItem && currentIndex == 0
        Button {
            withAnimation(animation) {
                currentIndex = max(currentIndex - 1, 0)
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3)
                .frame(width: 20, height: 30)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .opacity(isHidden ? 0 : 1)
        .allowsHitTesting(!isHidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 15)
        .padding(.top, 5)
    }

    /// Variable Glass Effect Blur
    @ViewBuilder
    func VariableGlassBlur(_ radius: CGFloat) -> some View {
        Rectangle()
            .fill(.clear)
            .glassEffect(.clear.tint(theme.glassTint), in: .rect)
            .blur(radius: radius)
            .padding([.horizontal, .bottom], -radius * 2)
            /// Only Visible for scaled screenshots!
            .opacity(items[currentIndex].zoomScale != 1 ? 1 : 0)
            .ignoresSafeArea()
    }


    var deviceCornerRadius: CGFloat {
        if let imageSize = items.first?.screenshot?.size {
            let ratio = screenshotSize.height / imageSize.height
            return screenshotCornerRadius * ratio
        }
        return 0
    }


    // MARK: - Theme

    enum Theme {
        case dark
        case light

        var colorScheme: ColorScheme {
            switch self {
            case .dark: return .dark
            case .light: return .light
            }
        }
        var primaryText: Color {
            switch self {
            case .dark: return .white
            case .light: return Color(.label)
            }
        }
        var secondaryText: Color {
            switch self {
            case .dark: return .white.opacity(0.7)
            case .light: return Color(.secondaryLabel)
            }
        }
        var screenshotBackground: Color {
            switch self {
            case .dark: return .black
            case .light: return .white
            }
        }
        var bezelOuter: Color {
            switch self {
            case .dark: return .white
            case .light: return Color(.systemGray4)
            }
        }
        var bezelInner: Color {
            switch self {
            case .dark: return .black
            case .light: return .black
            }
        }
        var glassTint: Color {
            switch self {
            case .dark: return .black.opacity(0.5)
            case .light: return .white.opacity(0.5)
            }
        }
    }


    // MARK: - Item

    struct Item: Identifiable {
        var id: UUID = UUID()
        var title: String
        var subtitle: String
        var screenshot: UIImage?
        var zoomScale: CGFloat = 1
        var zoomAnchor: UnitPoint = .center
    }

    var animation: Animation {
        .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

}

#Preview {
    ContentView()
}
