// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "little-daemon",
  products: [
    .library(name: "App", targets: ["App"]),
    .executable(name: "Run", targets: ["Run"])
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
    .package(url: "https://github.com/vapor-community/postgresql-provider.git", .upToNextMajor(from: "2.1.0")),
    .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.0.0")),
//    .package(url: "https://github.com/happiness9721/line-bot-sdk-swift.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/happiness9721/line-bot-sdk-swift.git", .branch("develop")),
  ],
  targets: [
    .target(name: "App", dependencies: ["LineBot", "FluentProvider", "PostgreSQLProvider", "LeafProvider"],
            exclude: [
              "Config",
              "Public",
              "Resources",
              ]),
    .target(name: "Run", dependencies: ["App"]),
    .testTarget(name: "AppTests", dependencies: ["App"])
  ]
)

