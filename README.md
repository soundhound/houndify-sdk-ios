# Houndify SDK for iOS
---
This library allows you to houndify your iOS app.

## What is Houndify

[Houndify](https://www.houndify.com) is a Developer Platform that allows anyone to add smart, voice enabled, conversational interfaces to anything with an Internet connection. Once you integrate with Houndify, your product will instantly understand a wide variety of questions and commands.

What makes Houndify unique is that rather than being one link in a chain of technologies, Houndify is a one-stop destination for all of the technologies needed to voice enable anything.

Including:

* Fast and large scale speech recognition
* Powerful natural language understanding
* Rich results covering the most popular domains such as Weather, Sports, Stocks, Hotels, Local Businesses, Home Automation, and more, with data provided from many popular companies including Uber, Yelp, and Expedia

Finally, you don't need to be a scientist to use Houndify. Developers can get up and running within minutes. It is also platform agnostic, so you can build it once and deploy it everywhere.

## Get started
First register a client on https://wwww.houndify.com. <br>

#### Swift Package Manager
1. In Xcode, go to **File > Add Packages...** and enter `https://github.com/soundhound/houndify-sdk-ios`.
2. Choose the current version (e.g. 1.9.2 or later) and add the `HoundifySDK` product to your target.

Or update your `Package.swift` directly:
```swift
dependencies: [
    .package(url: "https://github.com/soundhound/houndify-sdk-ios", from: "1.9.2")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "HoundifySDK", package: "houndify-sdk-ios")
        ]
    )
]
```

The SDK is also available for download at houndify.com

## Try it out
You can also download sample projects from our website for [Swift version](https://static.houndify.com/sdks/ios/v1.9.1/HoundSDK-Sample-Swift-1.9.1.zip) or [Objective-C version](https://static.houndify.com/sdks/ios/v1.9.1/HoundSDK-Sample-ObjC-1.9.1.zip).

## Documentation
Visit https://docs.houndify.com/sdks/docs/ios for reference documentation.

## Important Note
The SDK also requires the HoundifyPhraseSpotter framework. When using Swift Package Manager, it is pulled in automatically via the package dependency. If you are downloading manually, grab the [HoundifyPhraseSpotter framework](https://static.houndify.com/sdks/ios/v1.9.1/HoundSDK-1.9.1.zip) from the Houndify website.

## License
See the LICENSE file.

## Terms and conditions

Visit https://www.houndify.com/terms for terms and conditions.
