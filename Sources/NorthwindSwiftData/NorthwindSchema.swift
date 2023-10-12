//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation // for Data
import SwiftData

/// The type used to store monetary values in the database, currently `Decimal`.
public typealias Money = Decimal

// TBD: rather use an NSImage/UIImage?
/// A picture stored in the database, currently a `Data`.
public typealias Photo = Data

// In 15b2 `DateComponents` can't be used here.
/// The components of a date as a string, e.g. "1973-01-31".
public typealias YMDDate = String


// MARK: - v1

/**
 * The first version of the SwiftData Northwind schema.
 *
 * Instead of working w/ the schema directly, consider using the helper
 * functions contained in ``NorthwindStore``.
 */
public enum NorthwindSchema: VersionedSchema {
  
  public static let versionIdentifier = Schema.Version(0, 1, 0)
  
  public static let models : [ any PersistentModel.Type ] = [
    Product.self, Category.self, Order.self, OrderDetail.self,
    Employee.self, Customer.self, CustomerDemographic.self,
    Supplier.self, Shipper.self, Region.self, Territory.self
  ]
  
  public typealias Product             = NorthwindSwiftData.Product
  public typealias Category            = NorthwindSwiftData.Category
  public typealias Order               = NorthwindSwiftData.Order
  public typealias OrderDetail         = NorthwindSwiftData.OrderDetail
  public typealias Employee            = NorthwindSwiftData.Employee
  public typealias Customer            = NorthwindSwiftData.Customer
  public typealias CustomerDemographic = NorthwindSwiftData.CustomerDemographic
  public typealias Supplier            = NorthwindSwiftData.Supplier
  public typealias Shipper             = NorthwindSwiftData.Shipper
  public typealias Region              = NorthwindSwiftData.Region
  public typealias Territory           = NorthwindSwiftData.Territory
}
