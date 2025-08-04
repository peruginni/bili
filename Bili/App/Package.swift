// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "App",
            targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.21.0"),
        .package(url: "https://github.com/simibac/ConfettiSwiftUI.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
