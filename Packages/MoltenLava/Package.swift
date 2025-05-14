// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "MoltenLava",
    products: [
        .library(
            name: "MoltenLava",
            targets: ["MoltenLava"]
        )
    ],
    targets: [
        .target(
            name: "MoltenLava"),
        .testTarget(
            name: "MoltenLavaTests",
            dependencies: ["MoltenLava"]
        ),
    ]
)
