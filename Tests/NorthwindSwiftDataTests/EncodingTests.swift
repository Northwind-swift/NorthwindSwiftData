//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
@testable import NorthwindSwiftData

final class EncodingTests: XCTestCase {

  private var context : ModelContext!
  
  override func setUp() async throws {
    context = ModelContext(try TestContainer.northwind)
    XCTAssertFalse(context.autosaveEnabled)
  }
  
  func testCategoryEncoding() throws {
    let fd = FetchDescriptor<ProductCategory>(
      sortBy: [
        SortDescriptor(\.name)
      ]
    )
    let models = try context.fetch(fd)
    let model  = try XCTUnwrap(models.first)
    
    let data   = try JSONEncoder().encode(model)
    #if false
    let string = try XCTUnwrap(String(data: data, encoding: .utf8))
    print(string)
    #endif
    
    let json       = try JSONSerialization.jsonObject(with: data)
    let jsonDict   = try XCTUnwrap(json as? [ String : Any ])
    
    let idRootDict = try XCTUnwrap(jsonDict["id"] as? [ String: Any ])
    let idDict = try XCTUnwrap(idRootDict["implementation"] as? [String:Any])
    let id     = try XCTUnwrap(idDict["uriRepresentation"] as? String)
    
    XCTAssertTrue(id.hasPrefix("x-coredata://"))
    XCTAssertNotNil(idDict["primaryKey"])
    XCTAssertNotNil(idDict["storeIdentifier"])
    XCTAssertFalse(idDict["isTemporary"] as? Bool ?? false)
    XCTAssertEqual(idDict["entityName"] as? String, "Category")

    XCTAssertEqual(jsonDict["name"] as? String, "Beverages")
    XCTAssertEqual(jsonDict["info"] as? String,
                   "Soft drinks, coffees, teas, beers, and ales")
    
    let productIDs = try XCTUnwrap(jsonDict["products"] as? [ [ String: Any ] ])
    XCTAssertEqual(productIDs.count, 12)
  }
  
  #if true // Still crashes in Xcode 15 release (15A240d).
  func testProductEncoding() throws {
    try autoreleasepool {
      try _testProductEncoding()
    }
  }
  func _testProductEncoding() throws {
    let fd = FetchDescriptor<Product>(
      sortBy: [
        SortDescriptor(\.name)
      ]
    )
    let models = try context.fetch(fd)
    let model  = try XCTUnwrap(models.dropFirst(9).first)
    
    let data   = try JSONEncoder().encode(model)
#if false
    let string = try XCTUnwrap(String(data: data, encoding: .utf8))
    print(string)
#endif
    
    let json     = try JSONSerialization.jsonObject(with: data)
    let jsonDict = try XCTUnwrap(json as? [ String : Any ])
    do {
      let id  = try XCTUnwrap(jsonDict["id"] as? [ String : [ String : Any ] ])
      let imp = try XCTUnwrap(id["implementation"])
      let uri = try XCTUnwrap(imp["uriRepresentation"] as? String)
      let url = try XCTUnwrap(URL(string: uri))
      let sid = try XCTUnwrap(imp["storeIdentifier"] as? String)
      
      XCTAssertEqual(imp["entityName"]  as? String, "Product")
      XCTAssertEqual(imp["isTemporary"] as? Int, 0)
      XCTAssertEqual(url.scheme, "x-coredata")
      XCTAssertNotNil(imp["primaryKey"]) // p1283
      XCTAssertEqual(url.host, sid)
    }
    
    XCTAssertEqual(jsonDict["discontinued"] as? Int, 1)
    XCTAssertEqual(jsonDict["reorderLevel"] as? Int, 0)
    XCTAssertEqual(jsonDict["unitsInStock"] as? Int, 0)
    XCTAssertEqual(jsonDict["unitsOnOrder"] as? Int, 0)
    XCTAssertEqual(jsonDict["name"] as? String, "Chef Anton's Gumbo Mix")
    XCTAssertEqual(jsonDict["quantityPerUnit"] as? String, "36 boxes")
    XCTAssertEqual(String(describing: try XCTUnwrap(jsonDict["unitPrice"])),
                   "21.35")
    
    // An array of ID dicts
    let orderIDs = try XCTUnwrap(
      jsonDict["orderDetails"] as? [ [ String : [ String : Any ] ] ]
    )
    XCTAssertTrue(orderIDs.count > 200)
    
    do {
      let id  = try XCTUnwrap(orderIDs.first)
      let imp = try XCTUnwrap(id["implementation"])
      let uri = try XCTUnwrap(imp["uriRepresentation"] as? String)
      let url = try XCTUnwrap(URL(string: uri))
      let sid = try XCTUnwrap(imp["storeIdentifier"] as? String)
      
      XCTAssertEqual(imp["entityName"]  as? String, "OrderDetail")
      XCTAssertEqual(imp["isTemporary"] as? Int, 0)
      XCTAssertEqual(url.scheme, "x-coredata")
      XCTAssertNotNil(imp["primaryKey"]) // p1283
      XCTAssertEqual(url.host, sid)
    }
  }
  #endif
}
