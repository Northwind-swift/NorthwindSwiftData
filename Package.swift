// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "NorthwindSwiftData",
  platforms: [ .macOS(.v14), .iOS(.v17) ], // <= required for SwiftData
  products: [
    .library(name: "NorthwindSwiftData", targets:[ "NorthwindSwiftData" ]),
  ],
  targets: [
    .target(name: "NorthwindSwiftData",
            exclude: [ "Resources/LICENSE" ],
            resources: [
              .copy("Resources/Northwind.store"),
            ]),
    .testTarget(name: "NorthwindSwiftDataTests",
                dependencies: [ "NorthwindSwiftData" ])
  ]
) 
