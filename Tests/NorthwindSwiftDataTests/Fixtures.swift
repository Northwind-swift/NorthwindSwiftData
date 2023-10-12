//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//
@testable import NorthwindSwiftData

enum TestContainer {
  static var _northwind: ModelContainer?
  static var northwind: ModelContainer {
    get throws {
      if let c = _northwind { return c }
      _northwind = try NorthwindStore.readOnlyModelContainer()
      return _northwind!
    }
  }
}
