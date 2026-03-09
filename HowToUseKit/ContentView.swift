//
//  ContentView.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/6/26.
//

import SwiftUI

struct ContentView: View {
    private static let screenImage = UIImage(named: "screenshot")
    private static let title = "Welcome to iOS 26"
    private static let subtitle = "Introducing a new design with\nLiquid Glass."

    var body: some View {
        OnBoarding(tint: .orange, hideBezels: false, theme: .light, hidesBackButtonOnFirstItem: true, items: [
            .init(title: Self.title, subtitle: Self.subtitle, screenshot: Self.screenImage),
            .init(title: Self.title, subtitle: Self.subtitle, screenshot: Self.screenImage),
            .init(title: Self.title, subtitle: Self.subtitle, screenshot: Self.screenImage, zoomScale: 1.3, zoomAnchor: .bottom),
            .init(title: Self.title, subtitle: Self.subtitle, screenshot: Self.screenImage, zoomScale: 1.2, zoomAnchor: .init(x: 0.5, y: -0.1)),
            .init(title: Self.title, subtitle: Self.subtitle, screenshot: Self.screenImage, zoomScale: 1.0, zoomAnchor: .leading)
        ]) {
            print("Completed")
        }
    }
}

#Preview {
    ContentView()
}
