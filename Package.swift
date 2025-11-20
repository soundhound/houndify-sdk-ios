// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "HoundifySDK",
    platforms: [
        .iOS("15.6")
    ],
    products: [
        .library(
            name: "HoundifySDK",
            targets: [
                "HoundifySDK",
                "HoundifyPhraseSpotter"
            ]
        )
    ],
    targets: [
        .binaryTarget(
            name: "HoundifySDK",
            path: "HoundifySDK.xcframework"
        ),
        .binaryTarget(
            name: "HoundifyPhraseSpotter",
            path: "HoundifyPhraseSpotter.xcframework"
        )
    ]
)
