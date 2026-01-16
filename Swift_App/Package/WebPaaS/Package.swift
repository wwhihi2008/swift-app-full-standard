// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebPaaS",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WebPaaS",
            targets: ["WebPaaS"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "UIPaaS", path: "../UIPaaS"),
        .package(name: "URLRoute", path: "../URLRoute"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WebPaaS",
            dependencies: [.byName(name: "UIPaaS"),
                           .byName(name: "URLRoute")]),
    ]
)
