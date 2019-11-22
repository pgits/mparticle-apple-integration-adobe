// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "mparticle-apple-integration-adobe",
    platforms: [.iOS(.v9)],
    // platforms: [.iOS("9.0"), .macOS("10.10"), tvOS("9.0"), .watchOS("2.0")],
    products: [
        .library(name: "mparticle-apple-integration-adobe", targets: ["mparticle-apple-integration-adobe"])
    ],
    targets: [
        .target(
            name: "mparticle-apple-integration-adobe",
            path: "mParticle-Adobe"
        )
    ]
)
