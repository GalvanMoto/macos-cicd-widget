// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CICDWidget",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CICDWidget", targets: ["CICDWidget"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CICDWidget",
            dependencies: [],
            path: "Sources"
        )
    ]
)
