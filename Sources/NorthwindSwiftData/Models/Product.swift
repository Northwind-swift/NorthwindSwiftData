//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import SwiftData

/**
 * Describes a product that can be sold by Northwind GmbH.
 *
 * Products records have a unique ``name``, a ``unitPrice``, they track how
 * many of the products are in stock (``unitsInStock``) or on order
 * (``unitsOnOrder``), and whether they are ``discontinued``.
 *
 * Products can be grouped in ``Category`` objects (e.g. "Meat/Poultry").
 *
 * Products ordered by ``Customer``s are tracked in the ``Customer/orders``
 * relationship.
 * Note that those are specific product ``OrderDetail``s across all actual
 * ``Order``s!
 *
 * Each product only has a single ``Supplier`` assigned. Because it is 1982.
 *
 * Example products:
 * - "Camembert Pierrot"     ($34.00)
 * - "Genen Shouyu"          ($15.50)
 * - "Nord-Ost Matjeshering" ($25.89)
 */
@Model
public final class Product: Encodable {
  
  /// The unique name of the product.
  @Attribute(.unique, originalName: "ProductName")
  public var name            : String
  
  /// The quantity a unit of the product comes in.
  /// E.g. "12 - 12 oz jars" or "24 boxes x 2 pies".
  @Attribute(originalName: "QuantityPerUnit")
  public var quantityPerUnit : String?
  
  /// The default price of a unit of the product. Note that Northwind tracks
  /// the actual order prices in the ``OrderDetail`` associated w/ an
  /// ``Order``. I.e. prices are not static.
  @Attribute(originalName: "UnitPrice")
  public var unitPrice       : Money

  /// How many units of the product are in stock.
  @Attribute(originalName: "UnitsInStock")
  public var unitsInStock    : Int
  
  /// The number of outstanding product orders with the ``Supplier``.
  @Attribute(originalName: "UnitsOnOrder")
  public var unitsOnOrder    : Int
  
  /// How many of the products are usually reordered from the ``Supplier``.
  @Attribute(originalName: "ReorderLevel")
  public var reorderLevel    : Int
  
  /// Whether the product has been discontinued and is not available for
  /// ordering anymore.
  @Attribute(originalName: "Discontinued")
  public var discontinued    : Bool
  
  /// The sole supplier of the product to Northwind GmbH.
  @Relationship(deleteRule: .nullify, originalName: "SupplierID")
  public var supplier        : Supplier?
  
  /// The category of the product (e.g. "Meat/Poultry").
  @Relationship(deleteRule: .nullify, originalName: "CategoryID")
  public var category        : Category?
  
  /// All the orders the product has been a part of.
  /// Note that this points to the ``OrderDetail``s, not the ``Order``s
  /// itself (can be retrieved using the ``OrderDetail/order`` property.
  @Relationship(deleteRule: .cascade)
  public var orderDetails : [ OrderDetail ]
  
  
  /**
   * Create a new product record.
   *
   * - Parameters:
   *   - name:            The unique name of the product.
   *   - quantityPerUnit: The quantity a unit of the product comes in.
   *   - unitPrice:       The default price of a unit of the product.
   *   - unitsInStock:    How many units of the product are in stock.
   *   - unitsOnOrder:    The number of outstanding product orders with the
   *                      ``Supplier``.
   *   - reorderLevel:    How many of the products are usually reordered.
   *   - discontinued:    Whether the product has been discontinued and is not
   *                      available for ordering anymore (default: `false`).
   *   - supplier:        The sole supplier of the product to Northwind GmbH.
   *   - category:        The category of the product (e.g. "Meat/Poultry").
   *   - orders:          All the orders the product has been a part of.
   */
  public init(name: String,
              quantityPerUnit: String? = nil, unitPrice:    Money = 0,
              unitsInStock:    Int     = 0,   unitsOnOrder: Int   = 0,
              reorderLevel:    Int     = 0,   discontinued: Bool  = false,
              supplier:        Supplier? = nil,
              category:        Category? = nil,
              orderDetails:    [ OrderDetail ] = [])
  {
    self.name            = name
    self.quantityPerUnit = quantityPerUnit
    self.unitPrice       = unitPrice
    self.unitsInStock    = unitsInStock
    self.unitsOnOrder    = unitsOnOrder
    self.reorderLevel    = reorderLevel
    self.discontinued    = discontinued
    self.supplier        = supplier
    self.category        = category
    self.orderDetails    = orderDetails
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, name
    case quantityPerUnit, unitPrice, unitsInStock, unitsOnOrder, reorderLevel
    case discontinued
    case supplier, category, orderDetails
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id,   forKey: .id)
    try container.encode(name, forKey: .name)
    
    try container.encodeIfPresent(quantityPerUnit, forKey: .quantityPerUnit)
    try container.encodeIfPresent(unitPrice,       forKey: .unitPrice)
    try container.encodeIfPresent(unitsInStock,    forKey: .unitsInStock)
    try container.encodeIfPresent(unitsOnOrder,    forKey: .unitsOnOrder)
    try container.encodeIfPresent(reorderLevel,    forKey: .reorderLevel)
    if discontinued { try container.encode(true,   forKey: .discontinued) }
    
    try container.encodeIfPresent(supplier?.id,    forKey: .supplier)
    try container.encodeIfPresent(category?.id,    forKey: .category)
    
    if !orderDetails.isEmpty {
      try container.encode(orderDetails.map(\.id), forKey: .orderDetails)
    }
  }
}

extension Product: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Product[0x\(oid)]: \(name)"
    
    if let v = quantityPerUnit, !v.isEmpty { ms += " quantityPerUnit=\(v)" }
    if unitPrice    != 0            { ms += " unitPrice=\(unitPrice)" }
    if unitsInStock != 0 { ms += " unitsInStock=\(unitsInStock)" }
    else                 { ms += " out-of-stock" }
    if unitsOnOrder != 0 { ms += " unitsOnOrder=\(unitsOnOrder)" }
    if reorderLevel != 0 { ms += " reorderLevel=\(reorderLevel)" }

    if discontinued { ms += " discontinued" }

    #if false // don't trigger a fetch
    if !orderDetails.isEmpty  { ms += " items=#\(orderDetails.count)" }
    if let v = supplier { ms += " supplier=\(v.companyName)" }
    if let v = category { ms += " category=\(v.name)" }
    #endif
    return ms
  }
}
