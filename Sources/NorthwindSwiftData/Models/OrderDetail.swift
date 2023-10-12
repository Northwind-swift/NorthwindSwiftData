//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData

/**
 * Represents one product item that is part of an ``Order`` submitted by the
 * customer.
 *
 * It includes the ``Product`` ordered, the actual ``unitPrice``, ``discount``
 * and the ``quantity`` that was ordered.
 */
@Model
public final class OrderDetail: Encodable {
  
  /// How much one unit of the product costs as part of the ``Order``.
  @Attribute(originalName: "UnitPrice")
  public var unitPrice : Money
  
  /// How many of the products have been ordered.
  @Attribute(originalName: "Quantity")
  public var quantity  : Int
  
  /// How much discount was given on the product for the ``Order``.
  @Attribute(originalName: "Discount")
  public var discount  : Double
  
  // TBD: I think it is not possible to have non-optional toOne relationships?
  //      relationship properties? Records w/ such can't be inserted?
  
  /// The ``Order`` this detail is for.
  @Relationship(originalName: "OrderID")
  public var order     : Order!
  
  /// The ``Product`` this detail is for.
  @Relationship(originalName: "ProductID")
  public var product   : Product!
  
  /**
   * Create a new order detail.
   *
   * - Parameters:
   *   - unitPrice: How much one unit of the product costs.
   *   - quantity:  How many of the products have been ordered
   *                (defaults to 1).
   *   - discount:  How much discount was given on the product
   *                (defaults to 0).
   *   - order:     The ``Order`` the detail is for.
   *   - product:   The ``Product`` the detail is for.
   */
  public init(unitPrice: Money, quantity: Int = 1, discount: Double = 0.0,
              order:     Order, product: Product)
  {
    self.unitPrice = unitPrice
    self.quantity  = quantity
    self.discount  = discount
    self.order     = order
    self.product   = product
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id
    case unitPrice, quantity, discount
    case order, product
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id,        forKey: .id)
    try container.encode(unitPrice, forKey: .unitPrice)
    if quantity > 1 { try container.encode(quantity, forKey: .quantity) }
    if discount > 0 { try container.encode(discount, forKey: .discount) }
    
    try container.encodeIfPresent(order?  .id, forKey: .order)
    try container.encodeIfPresent(product?.id, forKey: .product)
  }
}

extension OrderDetail: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<OrderDetail[0x\(oid)]: unitPrice=\(unitPrice)"

    if quantity != 1 { ms += " #\(quantity)" }
    if discount != 0 { ms += " #\(discount)" }
    
    #if false // don't trigger a fetch
    if let v = order   { ms += " order=\(v.orderDate)" }
    if let v = product { ms += " product=\(v.firstName)" }
    #endif
    return ms
  }
}
