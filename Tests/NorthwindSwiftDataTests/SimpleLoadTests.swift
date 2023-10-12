//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
@testable import NorthwindSwiftData

final class SimpleLoadTests: XCTestCase {
  
  private var context : ModelContext!
  
  override func setUp() async throws {
    context = ModelContext(try TestContainer.northwind)
    XCTAssertFalse(context.autosaveEnabled)
  }
  
  func testProductCounts() throws {
    let fd = FetchDescriptor<Product>(predicate: nil, sortBy: [])
    let modelCount = try context.fetchCount(fd)
    XCTAssertEqual(modelCount, 77)
  }
  
  func testProductFetch() throws {
    let fd     = FetchDescriptor(sortBy: [SortDescriptor(\Product.name)])
    let models = try context.fetch(fd)
    XCTAssertEqual(models.count, 77)
    
    let model = try XCTUnwrap(models.first)
    XCTAssertEqual(model.name,            "Alice Mutton")
    XCTAssertEqual(model.quantityPerUnit, "20 - 1 kg tins")
    XCTAssertEqual(model.unitPrice,       Decimal(39))
    XCTAssertEqual(model.unitsInStock,    0)
    XCTAssertEqual(model.unitsOnOrder,    0)
    XCTAssertEqual(model.reorderLevel,    0)
    XCTAssertTrue (model.discontinued)
    
    // Relationships
    XCTAssertEqual(model.supplier?.companyName, "Pavlova, Ltd.")
    XCTAssertEqual(model.category?.name,        "Meat/Poultry")
  }
  
  func testProductOrderDetailsRelation() throws {
    var fd = FetchDescriptor<Product>(predicate: nil,
                                      sortBy: [ SortDescriptor(\.name) ])
    fd.fetchLimit = 1
    let products = try context.fetch(fd)
    XCTAssertEqual(products.count, 1)
    
    let firstProduct = try XCTUnwrap(products.first)
    XCTAssertEqual(firstProduct.name,               "Alice Mutton")
    XCTAssertEqual(firstProduct.orderDetails.count, 8048)
  }
  
  func testOrderDetailCounts() throws {
    let fd = FetchDescriptor<OrderDetail>(predicate: nil, sortBy: [])
    let modelCount = try context.fetchCount(fd)
    XCTAssertEqual(modelCount, 613964)
  }
  
  func testRegionRelationships() throws {
    let fd = FetchDescriptor(predicate: nil, sortBy: [ .init(\Region.name) ])
    let regions = try context.fetch(fd)
    XCTAssertEqual(regions.count, 4)
    
    XCTAssertEqual(regions.map(\.name),
                   ["Eastern", "Northern", "Southern", "Westerns"])
    
    let eastern = try XCTUnwrap(regions.first)
    XCTAssertEqual(eastern.name, "Eastern")
    XCTAssertEqual(eastern.territories.count, 19)
    XCTAssertNotNil(eastern.territories
      .firstIndex(where: { $0.name == "Greensboro" }))
    
    XCTAssertTrue(eastern.territories.first?.region === eastern)
  }
  
  func testEmployeeRelationships() throws {
    let fd = FetchDescriptor(predicate: nil, sortBy: [ .init(\Employee.lastName) ])
    let models = try context.fetch(fd)
    XCTAssertEqual(models.count, 9)
    
    XCTAssertEqual(models.map(\.lastName),
                   ["Buchanan", "Callahan", "Davolio", "Dodsworth", "Fuller",
                    "King", "Leverling", "Peacock", "Suyama"])
    
    let fuller = try XCTUnwrap(models.first(where: { $0.lastName == "Fuller" }))
    XCTAssertNil(fuller.reportsTo)
    XCTAssertEqual(fuller.managedEmployees.count, 5)
    XCTAssertTrue(fuller.managedEmployees.last?.reportsTo === fuller)
    
    // Note typo: "Georgetow"(n)
    XCTAssertEqual(fuller.territories.map(\.name).sorted(),
                   ["Bedford", "Boston", "Braintree", "Cambridge", "Georgetow",
                    "Louisville", "Westboro"])

    XCTAssertEqual(fuller.orders.count, 1814)

    let firstTerritory = try XCTUnwrap(fuller.territories.first)
    XCTAssertNotNil(firstTerritory.employees.first(where: { $0 === fuller }))
  }
  
  func testSupplierRelationships() throws {
    let fd = FetchDescriptor(sortBy: [ .init(\Supplier.companyName) ])
    let models = try context.fetch(fd)
    XCTAssertEqual(models.count, 29)
    
    let plutzer = try XCTUnwrap(models.first(where: {
      $0.companyName == "Plutzer Lebensmittelgroßmärkte AG"
    }))
    XCTAssertEqual(plutzer.contactName,  "Martin Bein")
    XCTAssertEqual(plutzer.contactTitle, "International Marketing Mgr.")
    XCTAssertEqual(plutzer.address,      "Bogenallee 51")
    
    // Nice :-)
    XCTAssertEqual(
      plutzer.homePage,
      "Plutzer (on the World Wide Web)" +
      "#http://www.microsoft.com/accessdev/sampleapps/plutzer.htm#"
    )
    
    XCTAssertEqual(plutzer.products.count, 5)
    XCTAssertEqual(plutzer.products.map(\.name).sorted(), [
      "Original Frankfurter grüne Soße", "Rhönbräu Klosterbier",
      "Rössle Sauerkraut", "Thüringer Rostbratwurst",
      "Wimmers gute Semmelknödel"
    ])
  }
  
  func testShipperRelationships() throws {
    let fd     = FetchDescriptor(sortBy: [ .init(\Shipper.companyName) ])
    let models = try context.fetch(fd)
    XCTAssertEqual(models.count, 3)
    
    XCTAssertEqual(models.map(\.companyName),
                   [ "Federal Shipping", "Speedy Express", "United Package" ])
    XCTAssertEqual(models.map(\.phone),
                   [ "(503) 555-9931", "(503) 555-9831", "(503) 555-3199" ])
    
    let model = try XCTUnwrap(models.first(where: {
      $0.companyName == "Federal Shipping"
    }))
    XCTAssertEqual(model.orders.count, 5396)
  }

  func testCustomerRelationships() throws {
    try autoreleasepool { // this seems to help avoid crashes?
      try _testCustomerRelationships()
    }
  }
  func _testCustomerRelationships() throws {
    let fd     = FetchDescriptor(sortBy: [ .init(\Customer.companyName) ])
    let models = try context.fetch(fd)
    XCTAssertEqual(models.count, 93)

    // WANDK|Die Wandernde Kuh|Rita Müller|Sales Representative|Adenauerallee 900|Stuttgart|Western Europe|70563|Germany|0711-020361|0711-035428

    let model = try XCTUnwrap(models.first(where: {
      $0.companyName == "Die Wandernde Kuh"
    }))
    XCTAssertEqual(model.code,         "WANDK")
    XCTAssertEqual(model.contactName,  "Rita Müller")
    XCTAssertEqual(model.contactTitle, "Sales Representative")
    XCTAssertEqual(model.city,         "Stuttgart")
    
    XCTAssertEqual(model.orders.count, 179)
    XCTAssertEqual(model.demographics.count, 0) // not filled in DB
  }
}
