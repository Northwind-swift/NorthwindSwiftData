# Frequently Asked Questions

A collection of questions and possible answers.

## Overview

Any question we should add: [info@zeezide.de](mailto:info@zeezide.de),
file a GitHub
[Issue](https://github.com/Northwind-swift/NorthwindSwiftData/issues),
or submit a GitHub PR w/ the answer. Thank you!


## General

### How is the database created?

The upstream database is available at GitHub:
[jpwhite3/northwind-SQLite3](https://github.com/jpwhite3/northwind-SQLite3).
This repository contains the full filled database w/ all records.

That SQLite database is then packaged as Swift using 
[Lighter](https://github.com/Lighter-swift) as
[NorthwindSQLite.swift](https://github.com/Northwind-swift/NorthwindSQLite.swift.git).
This uses the original database, and Swift functions to access the database are
generated automatically.

Finally that database is imported into SwiftData using an importer tool.
The resulting store is packaged as a resource as part of this
[NorthwindSwiftData](https://github.com/Northwind-swift/NorthwindSwiftData.git)
package.

> The import into SwiftData consume a lot of memory and takes a few hours.


### How big is the database?

The upstream SQLite database isn't very big, just about 24MB.
The SwiftData variant of the store is about twice as big, ~50MB.
(Yes, the SwiftData store is _also_ just a SQLite store, but carries additional
 metadata within.)

| Model           | Count  |
|-----------------|--------|
| ``Product``     |     77 |
| ``Category``    |      8 |
| ``Supplier``    |     29 |
| ``Shipper``     |      3 |
| ``Territory``   |     53 |
| ``Customer``    |     93 |
| ``Order``       |  16515 |
| ``OrderDetail`` | 613964 |


### Does this require SwiftUI or can I use it in UIKit as well?

The database works with both, SwiftUI and UIKit.
Or in AppKit, in a Swift tool or on the server side.
As long as 
[SwiftData](https://developer.apple.com/documentation/swiftdata)
is available, which currently requires iOS 17+ and macOS 14+.

If SwiftData seems likable, but those deployment targets cannot be used yet,
[ManagedModels](https://github.com/Data-swift/ManagedModels/) might be worth
a look.
It is a SwiftData like `@Model` for 
[CoreData](https://developer.apple.com/documentation/coredata),
and backports to earlier OS versions.


### Is it possible to use the database in SwiftUI Previews?

Yes. E.g. a preview can use the readonly container contained in the package:
```swift
#Preview {
    ContentView()
        .modelContainer(try! NorthwindStore.readOnlyModelContainer())
}
```

### Something isn't working right, how do I file a Radar?

Please file a GitHub
 [Issue](https://github.com/Northwind-swift/NorthwindSwiftData.git/issues).
Thank you very much.
