# Getting Started

Using NorthwindSwiftData in SwiftUI.

## Introduction

This article shows how to setup a small SwiftUI Xcode project to work with
NorthwindSwiftData.
It is a conversion of the Xcode template project for CoreData.


## Creating the Xcode Project and Adding NorthwindSwiftData

1. Create a new SwiftUI project in Xcode, e.g. a Multiplatform/App project or an
   iOS/App project. (it does work for UIKit as well!)
2. Choose "None" as the "Storage" (instead of "SwiftData" or "Core Data"),
   NorthwindSwiftData already has the storage setup for you.
3. Select "Add Package Dependencies" in Xcode's "File" menu to add the
   NorthwindSwiftData package.
4. In the **search field** (yes!) of the packages panel,
   paste in the URL of the package:
   `https://github.com/Northwind-swift/NorthwindSwiftData.git`,
   and press "Add Package" twice.


## Configure the App to use Northwind

In the app configuration, add the NorthwindStore as the apps
[ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer):

```swift
import NorthwindSwiftData

@main
struct NorthwindApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(try! NorthwindStore.modelContainer())
    }
}
```

This takes the prefilled database contained in the package and copies
that to the users Application Support directory.
So that it can be _edited_ by the user.
The ``NorthwindStore/modelContainer(bootstrapIfMissing:_:)`` function has a few 
options to configure that process.

Alternatively, if readonly access is sufficient,
the ``NorthwindStore/readOnlyModelContainer()`` function can be used to get 
direct access to the database contained within the package.


## Write a SwiftUI View that works w/ the Database

A small example view to display all the products in a SwiftUI List.

```swift
import SwiftUI
import NorthwindSwiftData

struct ContentView: View {

    @Query(sort: \Product.name)
    private var products: [ Product ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(products) { product in
                    Text(verbatim: product.name)
                }
            }
            .navigationTitle("Products")
        }
    }    
}

#Preview {
    ContentView()
        .modelContainer(try! NorthwindStore.readOnlyModelContainer())
}
```
