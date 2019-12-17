// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MetalSmith",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .executable(name: "mtlsmith", targets: ["MetalSmithGenerator", "MetalSmith"]),
        .library(name: "MetalSmith", targets: ["MetalSmith"]),
        .library(name: "MetalSmithUI", targets: ["MetalSmithUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", .exact("0.7.1")),
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.2")),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", .exact("2.7.0")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MetalSmithGenerator",
            dependencies: ["MetalSmith", "PathKit", "Commander", "Logging", "StencilSwiftKit"]),
        .target(
            name: "MetalSmith",
            dependencies: ["PathKit", "Logging"]),
        .target(
            name: "MetalSmithUI",
            dependencies: ["MetalSmith"]),
        .testTarget(
            name: "MetalSmithTests",
            dependencies: ["MetalSmith"]),
    ]
)
