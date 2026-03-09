//
//  ContentView.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let image = UIImage(named: "screenshot")
        let title = "Welcome to iOS 26"
        let subtitle = "Introducing a new design with\nLiquid Glass."
        OnBoarding(tint: .orange, hideBezels: false, items: [
            .init(id: 0, title: title, subtitle: subtitle, screenshot: image),
            .init(id: 1, title: title, subtitle: subtitle, screenshot: image),
            .init(id: 2, title: title, subtitle: subtitle, screenshot: image, zoomScale: 1.3, zoomAnchor: .bottom),
            .init(id: 3, title: title, subtitle: subtitle, screenshot: image, zoomScale: 1.2, zoomAnchor: .init(x: 0.5, y: -0.1)),
            .init(id: 4, title: title, subtitle: subtitle, screenshot: image, zoomScale: 1.0, zoomAnchor: .leading)
        ]) {
            print("Completed")
        }
        
    }
}

#Preview {
    ContentView()
}
