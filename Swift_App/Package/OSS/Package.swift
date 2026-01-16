// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OSS",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OSS",
            targets: ["OSS"]),
    ],
    dependencies: [
        .package(url: "http://code.zcabc.com/ww666/alibabacloud-oss-swift-sdk-v2.git", exact: "0.1.1")],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OSS", dependencies: [.product(name: "AlibabaCloudOSS", package: "alibabacloud-oss-swift-sdk-v2")]),
    ]
)
