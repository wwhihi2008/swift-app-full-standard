// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIPaaS",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UIPaaS",
            targets: ["UIPaaS"]),
    ],
    dependencies: [
        .package(name: "OSS", path: "../OSS"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UIPaaS",
            dependencies: [.byName(name: "OSS")],
            resources: [.process("Assets/IconFont/iconfont.ttf"),
                        .process("Assets/IconFont/iconfont.json")]),
    ]
)
