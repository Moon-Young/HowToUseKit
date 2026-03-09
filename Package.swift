// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HowToUseKit",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "HowToUseKit",
            targets: ["HowToUseKit"]
        )
    ],
    targets: [
        .target(
            name: "HowToUseKit",
            path: "Sources/HowToUseKit",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
