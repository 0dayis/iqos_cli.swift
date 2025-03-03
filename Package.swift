// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iqos_cli",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/rensbreur/SwiftTUI.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "iqos_cli",
            dependencies: ["SwiftTUI"]),
        .testTarget(name: "HCI_Gather"),
        // .testTarget(name: "TestTUI", dependencies: ["SwiftTUI"], path: "Tests/TestTUI"),
    ]
)
