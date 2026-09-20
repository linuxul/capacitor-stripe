// swift-tools-version: 5.9
import Foundation
import PackageDescription

// Apps override this dependency with the @capacitor/ios they installed. To build this package on its own
// against a local runtime, point CAPACITOR_IOS_PATH at it.
let capacitor: Package.Dependency
if let path = ProcessInfo.processInfo.environment["CAPACITOR_IOS_PATH"] {
    capacitor = .package(name: "capacitor-swift-pm", path: path)
} else {
    capacitor = .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
}

let package = Package(
    name: "CapacitorCommunityStripe",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CapacitorCommunityStripe",
            targets: ["StripePlugin"])
    ],
    dependencies: [
        capacitor,
        .package(url: "https://github.com/stripe/stripe-ios-spm.git", .upToNextMinor(from: "26.6.0"))
    ],
    targets: [
        .target(
            name: "StripePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "StripePaymentSheet", package: "stripe-ios-spm"),
                .product(name: "StripeApplePay", package: "stripe-ios-spm")
            ],
            path: "ios/Sources/StripePlugin"),
        .testTarget(
            name: "StripePluginTests",
            dependencies: ["StripePlugin"],
            path: "ios/Tests/StripePluginTests")
    ]
)
