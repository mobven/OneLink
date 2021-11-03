// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MBOneLink",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "MBOneLink",
            targets: ["MBOneLink"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mobven/MobKitCore.git", .branch("develop"))
    ],
    targets: [
        .target(
            name: "MBOneLink",
            dependencies: ["MobKitCore"]
        ),
        .testTarget(
            name: "MBOneLinkTests",
            dependencies: ["MBOneLink"]
        )
    ]
)
