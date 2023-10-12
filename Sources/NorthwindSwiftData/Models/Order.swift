//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import SwiftData

/**
 * Represents an order w/ the Northwind GmbH.
 *
 * The order object consists of a few core data items and the set of
 * ordered products w/ the prices and discounts.
 * The latter is represented by the ``OrderDetail`` objects (accessed using
 * the ``details`` property).
 *
 * And order always ships to one specific ``Customer``, though the shipping
 * address can be different to the ``Customer/structuredAddress``.
 *
 * Also, there is one ``Employee`` assigned to deal with each order.
 * And once it ships, a ``Shipper``. Note that one Northwind order always
 * ships to the same location (that is why people buy SAP and not MS).
 *
 * Order conforms to the ``AddressHolder`` protocol, which allows
 * address retrieval as either an ``StructuredAddress`` structure using the
 * ``StructuredAddressProvider/structuredAddress`` property.
 * Or as a `CNPostalAddress` using the
 * ``StructuredAddressProvider/postalAddress`` property.
 */
@Model
public final class Order: Encodable {
  
  /// When the order was issued.
  @Attribute(originalName: "OrderDate")
  public var orderDate      : Date
  
  /// When the ordered ``Product``s have to arrive at the ``Customer``s site.
  @Attribute(originalName: "RequiredDate")
  public var requiredDate   : Date
  
  /// When the order has been shipped by the ``Shipper``.
  @Attribute(originalName: "ShippedDate")
  public var shippedDate    : Date?
  
  // TBD: is this money?? or weight?, sample: 559.75
  /// The weight of the ordered products.
  @Attribute(originalName: "Freight")
  public var freight        : Money
  
  /**
   * The recipient name of the address the products should ship to.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "ShipName")
  public var shipName       : String
  
  /**
   * The address/street the products should ship to.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "ShipAddress")
  public var shipAddress    : String?

  /**
   * The city the products should ship to.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "ShipCity")
  public var shipCity       : String?

  /**
   * The region/state the products should ship to.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "ShipRegion")
  public var shipRegion     : String?

  /**
   * The postal code of the address the products should ship to.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "ShipPostalCode")
  public var shipPostalCode : String?
  
  /**
   * The country the products should ship to.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "ShipCountry")
  public var shipCountry    : String?
  
  /// The products, and the associated quantities and discounts, that are
  /// part of the order.
  @Relationship(deleteRule: .cascade)
  public var details        : [ OrderDetail ]
  
  /// The customer that issues the order.
  @Relationship(deleteRule: .nullify, originalName: "CustomerID")
  public var customer       : Customer?
  
  /// The employee responsible for fulfilling the order.
  @Relationship(deleteRule: .nullify, originalName: "EmployeeID")
  public var employee       : Employee?
  
  /// The shipping company that is going to process the order.
  @Relationship(deleteRule: .nullify, originalName: "ShipVia",
                inverse: \Shipper.orders)
  public var shipVia        : Shipper?
  
  
  // MARK: - Init
  
  /**
   * Create a new order object.
   *
   * - Parameters:
   *   - orderDate:      When the order was issued.
   *   - requiredDate:   When the ordered ``Product``s have to arrive at the
   *                     ``Customer``s site.
   *   - shippedDate:    When the order has been shipped by the ``Shipper``.
   *   - freight:        The weight of the ordered products.
   *   - shipName:       The recipient name on the shipping address.
   *   - shipAddress:    The address/street of the shipping address.
   *   - shipCity:       The city of the shipping address.
   *   - shipRegion:     The region/state of the shipping address.
   *   - shipPostalCode: The postal code of the shipping address.
   *   - shipCountry:    The country of the shipping address.
   *   - details:        The products, and the associated quantities and
   *                     discounts, that are part of the order.
   *   - customer:       The customer that issues the order.
   *   - employee:       The employee responsible for fulfilling the order.
   *   - shipVia:        The shipping company that is going to process the order.
   */
  public init(orderDate:      Date,          requiredDate: Date,
              shippedDate:    Date?   = nil, freight:      Money,
              shipName:       String,        shipAddress:  String? = nil,
              shipCity:       String? = nil, shipRegion:   String? = nil,
              shipPostalCode: String? = nil, shipCountry:  String? = nil,
              details:  [ OrderDetail ] = [],
              customer: Customer? = nil,
              employee: Employee? = nil,
              shipVia:  Shipper?  = nil)
  {
    self.orderDate      = orderDate
    self.requiredDate   = requiredDate
    self.shippedDate    = shippedDate
    self.freight        = freight
    self.shipName       = shipName
    self.shipAddress    = shipAddress
    self.shipCity       = shipCity
    self.shipRegion     = shipRegion
    self.shipPostalCode = shipPostalCode
    self.shipCountry    = shipCountry
    self.details        = details
    self.customer       = customer
    self.employee       = employee
    self.shipVia        = shipVia
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id
    case orderDate, requiredDate, shippedDate, freight
    case shipAddress
    
    case details, customer, employee, shipVia
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id,                    forKey: .id)
    try container.encode(orderDate,             forKey: .orderDate)
    try container.encode(requiredDate,          forKey: .requiredDate)
    try container.encodeIfPresent(shippedDate,  forKey: .shippedDate)
    try container.encode(freight,               forKey: .freight)
    
    try container.encodeIfPresent(structuredAddress,  forKey: .shipAddress)
    
    try container.encodeIfPresent(customer?.id, forKey: .customer)
    try container.encodeIfPresent(employee?.id, forKey: .employee)
    try container.encodeIfPresent(shipVia? .id, forKey: .shipVia)
    
    if !details.isEmpty {
      try container.encode(details.map(\.id),   forKey: .details)
    }
  }
}


extension Order: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Order[0x\(oid)]:"
    
    ms += " ordered=\(orderDate)"
    ms += " required=\(requiredDate)"
    if let v = shippedDate { ms += " shipped=\(v)" }
    
    ms += " freight=\(freight)"
    ms += " ship-to=\(shipName)"
    if let v = shipCity    { ms += " \(v)" }
    if let v = shipCountry { ms += " \(v)" }

    #if false // don't trigger a fetch
    if !details.isEmpty { ms += " items=#\(details.count)" }
    if let v = customer { ms += " customer=\(v.companyName)" }
    if let v = employee { ms += " employee=\(v.firstName)" }
    if let v = shipVia  { ms += " shipper=\(v.companyName)" }
    #endif
    return ms
  }
}


extension Order: StructuredAddressProvider {
  
  public var structuredAddress: StructuredAddress? {
    let address = StructuredAddress(
      name: shipName,
      address: shipAddress, city: shipCity, region: shipRegion,
      postalCode: shipPostalCode, country: shipCountry
    )
    return address.isEmpty ? nil : address
  }
}
