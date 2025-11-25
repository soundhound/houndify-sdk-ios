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
                "HoundifySDKTarget"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/soundhound/houndify-sdk-ios-phrasespotter",
            from: "1.9.2"
        )
    ],
    targets: [
        .target(
            name: "HoundifySDKTarget",
            dependencies: [
                "HoundifySDK",
                .product(name: "HoundifyPhraseSpotter",
                         package: "houndify-sdk-ios-phrasespotter")
            ],
            path: "./Sources/HoundifySDKTarget"
        ),
        .binaryTarget(
            name: "HoundifySDK",
            path: "HoundifySDK.xcframework"
        )
    ]
)
