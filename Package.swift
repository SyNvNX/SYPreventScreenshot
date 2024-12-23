// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SYPreventScreenshot",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SYPreventScreenshot",
            targets: ["SYPreventScreenshot"]),
        .library(
            name: "SYPreventScreenshotSDWebImage",
            targets: ["SYPreventScreenshotSDWebImage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SYPreventScreenshot",
            dependencies: [],
            path: "Sources",
            sources: [
                "SYPreventScreenshot/Core",
                "SYPreventScreenshot/WebServer/Core",
                "SYPreventScreenshot/WebServer/Requests",
                "SYPreventScreenshot/WebServer/Responses"
            ],
            cSettings: [
                .headerSearchPath("SYPreventScreenshot/Core"),
                .headerSearchPath("SYPreventScreenshot/WebServer/Core"),
                .headerSearchPath("SYPreventScreenshot/WebServer/Requests"),
                .headerSearchPath("SYPreventScreenshot/WebServer/Responses")
            ]
        ),
        .target(
            name: "SYPreventScreenshotSDWebImage",
            dependencies: [
                "SYPreventScreenshot",
                .product(name: "SDWebImage", package: "SDWebImage")
            ]
        )
    ]
)
