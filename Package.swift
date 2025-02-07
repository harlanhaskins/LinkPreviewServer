// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LinkPreviewServer",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/harlanhaskins/LinkPreviewSwift.git", branch: "main"),
        .package(url: "https://github.com/swhitty/FlyingFox.git", from: "0.20.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "LinkPreviewServer",
            dependencies: [
                "FlyingFox",
                .product(name: "LinkPreview", package: "LinkPreviewSwift")
            ]
        ),
    ]
)
