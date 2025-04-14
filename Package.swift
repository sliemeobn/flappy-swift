// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flappy-swift",
    platforms: [.macOS(.v15)],
    products: [],
    dependencies: [
        .package(url: "https://github.com/sliemeobn/elementary-dom", branch: "main"),
        .package(url: "https://github.com/sliemeobn/elementary-css", branch: "main"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.26.1"),
    ],
    targets: [
        .executableTarget(
            name: "flappy-swift",
            dependencies: [
                .product(name: "ElementaryDOM", package: "elementary-dom"),
                .product(name: "ElementaryCSS", package: "elementary-css"),
            ]
        )
    ]
)
