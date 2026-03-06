//
//  ContentView.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let image = UIImage(named: "Screen")
        let title = "Welcome to iOS 26"
        let subtitle = "Introducing a new design with\nLiquid Glass."
        OnBoarding(items: [
            .init(id: 0, title: title, subtitle: subtitle, screenshot: image),
            .init(id: 1, title: title, subtitle: subtitle, screenshot: image),
            .init(id: 2, title: title, subtitle: subtitle, screenshot: image),
            .init(id: 3, title: title, subtitle: subtitle, screenshot: image),
            .init(id: 4, title: title, subtitle: subtitle, screenshot: image)
        ])
    }
}

#Preview {
    ContentView()
}
