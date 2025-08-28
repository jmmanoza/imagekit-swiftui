// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "ImageKit",
            targets: ["ImageKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ImageKit",
            dependencies: [],
//            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ImageKitTests",
            dependencies: ["ImageKit"]
        ),
    ]
)
