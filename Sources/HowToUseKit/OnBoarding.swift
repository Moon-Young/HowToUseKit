//
//  OnBoarding.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/6/26.
//

import SwiftUI
import UIKit
import CoreText

// MARK: - Font Registration

private let registerFontsOnce: Void = {
    let fontNames = [
        "Inter_18pt-Regular",
        "Inter_18pt-Medium",
        "Inter_18pt-SemiBold",
        "Inter_18pt-Bold"
    ]
    for name in fontNames {
        guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
            print("[HowToUseKit] Font not found: \(name).ttf")
            continue
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}()

// MARK: - OnBoarding

public struct OnBoarding: View {
    public var tint: Color
    public var hideBezels: Bool
    public var screenshotCornerRadius: CGFloat
    public var theme: Theme
    public var hidesBackButtonOnFirstItem: Bool
    public var items: [Item]
    public var onComplete: () -> Void

    @State private var currentIndex: Int = 0
    @State private var screenshotSize: CGSize = .zero

    public init(
        tint: Color = .blue,
        hideBezels: Bool = false,
        screenshotCornerRadius: CGFloat = 70,
        theme: Theme = .dark,
        hidesBackButtonOnFirstItem: Bool = true,
        items: [Item],
        onComplete: @escaping () -> Void
    ) {
        self.tint = tint
        self.hideBezels = hideBezels
        self.screenshotCornerRadius = screenshotCornerRadius
        self.theme = theme
        self.hidesBackButtonOnFirstItem = hidesBackButtonOnFirstItem
        self.items = items
        self.onComplete = onComplete
        _ = registerFontsOnce
    }

    public var body: some View {
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
                    GlassBlurBackground(18, tint: theme.glassTint)
                }
                BackButton()

            }
            .preferredColorScheme(theme.colorScheme)
        }
    }


    // MARK: - Clip Shape

    /// iOS 26: ConcentricRectangle / iOS 18~25: RoundedRectangle
    var clipShape: AnyShape {
        if #available(iOS 26, *) {
            return AnyShape(ConcentricRectangle(corners: .concentric, isUniform: true))
        } else {
            return AnyShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
        }
    }


    // MARK: - Screenshot View

    @ViewBuilder
    func ScreenshotView() -> some View {
        let shape = clipShape
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
            }, set: { _ in }))
        }
        .clipShape(shape)
        .overlay {
            if screenshotSize != .zero && !hideBezels {
                ZStack {
                    shape.stroke(theme.bezelOuter, lineWidth: 6)
                    shape.stroke(theme.bezelInner, lineWidth: 2)
                    shape.stroke(theme.bezelInner, lineWidth: 6).padding(4)
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


    // MARK: - Text Content View

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


    // MARK: - Indicator View

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


    // MARK: - Continue Button

    @ViewBuilder
    func ContinueButton() -> some View {
        let label = Text(currentIndex == items.count - 1 ? "Get Started" : "Continue")
            .font(.custom("Inter18pt-Medium", size: 17))
            .contentTransition(.numericText())
            .padding(.vertical, 6)

        if #available(iOS 26, *) {
            Button {
                handleContinue()
            } label: {
                label
            }
            .tint(tint)
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .padding(.horizontal, 30)
        } else {
            Button {
                handleContinue()
            } label: {
                label
                    .frame(maxWidth: .infinity)
            }
            .tint(tint)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
        }
    }

    private func handleContinue() {
        if currentIndex == items.count - 1 {
            onComplete()
        } else {
            withAnimation(animation) {
                currentIndex += 1
            }
        }
    }


    // MARK: - Back Button

    @ViewBuilder
    func BackButton() -> some View {
        let isHidden = hidesBackButtonOnFirstItem && currentIndex == 0

        if #available(iOS 26, *) {
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
        } else {
            Button {
                withAnimation(animation) {
                    currentIndex = max(currentIndex - 1, 0)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .frame(width: 20, height: 30)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .opacity(isHidden ? 0 : 1)
            .allowsHitTesting(!isHidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 15)
            .padding(.top, 5)
        }
    }


    // MARK: - Glass Blur Background

    @ViewBuilder
    func GlassBlurBackground(_ radius: CGFloat, tint: Color) -> some View {
        if #available(iOS 26, *) {
            Rectangle()
                .fill(.clear)
                .glassEffect(.clear.tint(tint), in: .rect)
                .blur(radius: radius)
                .padding([.horizontal, .bottom], -radius * 2)
                .opacity(items[currentIndex].zoomScale != 1 ? 1 : 0)
                .ignoresSafeArea()
        } else {
            Rectangle()
                .fill(tint)
                .blur(radius: radius)
                .padding([.horizontal, .bottom], -radius * 2)
                .opacity(items[currentIndex].zoomScale != 1 ? 1 : 0)
                .ignoresSafeArea()
        }
    }


    // MARK: - Helpers

    var deviceCornerRadius: CGFloat {
        if let imageSize = items.first?.screenshot?.size {
            let ratio = screenshotSize.height / imageSize.height
            return screenshotCornerRadius * ratio
        }
        return 0
    }

    var animation: Animation {
        .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }
}


// MARK: - Theme

extension OnBoarding {
    public enum Theme {
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
}


// MARK: - Item

extension OnBoarding {
    public struct Item: Identifiable {
        public var id: UUID
        public var title: String
        public var subtitle: String
        public var screenshot: UIImage?
        public var zoomScale: CGFloat
        public var zoomAnchor: UnitPoint

        public init(
            id: UUID = UUID(),
            title: String,
            subtitle: String,
            screenshot: UIImage? = nil,
            zoomScale: CGFloat = 1,
            zoomAnchor: UnitPoint = .center
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.screenshot = screenshot
            self.zoomScale = zoomScale
            self.zoomAnchor = zoomAnchor
        }
    }
}
