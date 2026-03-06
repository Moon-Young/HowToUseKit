//
//  OnBoarding.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/6/26.
//

import SwiftUI

struct OnBoarding: View {
    var tint: Color = .blue
    var items: [Item]
    /// View Properties
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 10) {
                TextContentView()
                IndicatorView()
                ContinueButton()
            }
            .padding(.top, 20)
            .padding(.horizontal, 15)
            .frame(height: 210)
            BackButton()
            
        }
        .preferredColorScheme(.dark)
    }
    
        
    
    /// Text Content View
    @ViewBuilder
    func TextContentView() -> some View {
        GeometryReader {
            let size = $0.size
            
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        let isActive = currentIndex == index

                        VStack(spacing: 6) {
                            Text(item.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .foregroundStyle(.white)

                            Text(item.subtitle)
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.8))

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
                    .fill(.white.opacity(isActive ? 1 : 0.4))
                    .frame(width: isActive ? 25 : 6, height: 6)
            }
        }
    }
    
    /// Bottom Continue Button
    @ViewBuilder
    func ContinueButton() -> some View {
        Button {
            withAnimation(animation) {
                currentIndex = min(currentIndex + 1, items.count - 1)
            }
        } label: {
            Text("Continue")
                .fontWeight(.medium)
                .padding(.vertical, 6)
        }
        .tint(tint)
        .buttonStyle(.glassProminent)
        .buttonSizing(.flexible)
        .padding(.horizontal, 30)
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    /// Back Button
    @ViewBuilder
    func BackButton() -> some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 15)
        .padding(.top, 5)
    }
    
    
    
    struct Item: Identifiable {
        var id: Int
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
