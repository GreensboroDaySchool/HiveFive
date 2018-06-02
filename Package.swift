// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Hive5Server",
    products: [
        .library(
            name: "Hive5Common",
            targets: ["Hive5Common"]),
        .executable(
            name: "Hive5Server",
            targets: ["Hive5Server"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/websocket.git", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "Hive5Common",
            dependencies: [],
            path: "./Hive5Common/Source"),
        .target(
            name: "Hive5Server",
            dependencies: [
                "Hive5Common",
                "WebSocket"
            ],
            path: "./Hive5Server")
    ]
)
