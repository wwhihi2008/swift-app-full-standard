// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DDApplication",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DDApplication",
            targets: ["DDApplication"]),
    ],
    dependencies: [
        .package(name: "APIGateway", path: "../APIGateway"),
        .package(name: "UIPaaS", path: "../UIPaaS"),
        .package(name: "URLRoute", path: "../URLRoute"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DDApplication",
            dependencies: [.byName(name: "APIGateway"),
                           .byName(name: "UIPaaS"),
                           .byName(name: "URLRoute")])
    ]
)
