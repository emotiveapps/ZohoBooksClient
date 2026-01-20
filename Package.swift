// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ZohoBooksClient",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "ZohoBooksClient",
            targets: ["ZohoBooksClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/OAuthenticator", from: "0.3.0"),
        .package(url: "https://github.com/emotiveapps/MimeTypeEnum", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ZohoBooksClient",
            dependencies: ["OAuthenticator", "MimeTypeEnum"]
        ),
        .testTarget(
            name: "ZohoBooksClientTests",
            dependencies: ["ZohoBooksClient"]
        ),
    ]
)
