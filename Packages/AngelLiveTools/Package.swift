// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AngelLiveTools",
    platforms: [.macOS(.v14),
                .iOS(.v17),
                .tvOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AngelLiveTools",
            targets: ["AngelLiveTools"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/pcccccc/LiveParse", .upToNextMajor(from: "1.4.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AngelLiveTools",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "LiveParse", package: "LiveParse"),
            ]
        ),
        .testTarget(
            name: "AngelLiveToolsTests",
            dependencies: ["AngelLiveTools"]
        ),
    ]
)
