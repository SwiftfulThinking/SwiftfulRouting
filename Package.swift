// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftfulRouting",
    platforms: [
        .macOS(.v12), .iOS(.v17), .tvOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftfulRouting",
            targets: ["SwiftfulRouting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftfulThinking/SwiftfulRecursiveUI.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftfulRouting",
            dependencies: [
                .product(name: "SwiftfulRecursiveUI", package: "SwiftfulRecursiveUI")
            ]),
        .testTarget(
            name: "SwiftfulRoutingTests",
            dependencies: ["SwiftfulRouting"]),
    ]
)
