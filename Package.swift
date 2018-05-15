// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Hive5",
    products: [
        .library(
            name: "Hive5Common",
            targets: ["Hive5Common"])
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git", from: "1.7.3")
    ],
    targets: [
        .target(
            name: "Hive5Common",
            dependencies: [
                "LoggerAPI"
            ],
            path: "./Hive5Common/Source"),
    ]
)
