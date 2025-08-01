// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "App",
            targets: ["App"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.21.0"),
//        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.1"),
        .package(url: "https://github.com/simibac/ConfettiSwiftUI.git", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "App",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI"),
//                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
//        .target(
//            name: "SnapshotTesting",
//            dependencies: [
//                
//            ],
//            resources: [
//                //.process("Resources")
//            ]
//        ),
//        .target(
//            name: "SwiftUIHelpers",
//            dependencies: [
//                .product(name: "Gen", package: "swift-gen")
//            ]
//        ),
//        .testTarget(
//            name: "AppTest",
//            dependencies: [
//                 "App",
//                 .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//            ]
//        ),
//        .testTarget(
//            name: "AppStoreSnapshotTests",
//            dependencies: [
//                "App",
//                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
//            ],
//            exclude: [
//                "__Snapshots__"
//            ],
//            resources: [
//                .process("Resources")
//            ]
//        ),
    ]
)
