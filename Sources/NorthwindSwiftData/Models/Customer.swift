//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData

/**
 * A company that is a customer (or to be customer) of the Northwind GmbH.
 *
 * Northwind is a trading company that refuses to serve individual customers.
 *
 * A customer can have unstructured information about a contact,
 * i.e. the contacts name (``Customer/contactName``) and her title at the
 * customers company (``Customer/contactTitle``).
 *
 * The ``Order``s a customer has issued at Northwind GmbH is stored in the
 * ``Customer/orders`` property.
 *
 * Customer conforms to the ``AddressHolder`` protocol, which allows
 * address retrieval as either an ``StructuredAddress`` structure using the
 * ``StructuredAddressProvider/structuredAddress`` property.
 * Or as a `CNPostalAddress` using the
 * ``StructuredAddressProvider/postalAddress`` property.
 */
@Model
public final class Customer: Encodable, AddressHolder {
  
  /// A unique 5-character ID for the customer, e.g. `LONEP`.
  @Attribute(.unique, originalName: "CustomerID")
  public var code         : String
  
  /// The name of the company, does NOT have to be unique!
  @Attribute(originalName: "CompanyName")
  public var companyName  : String
  // Note: That this isn't unique, might be a bug in NorthwindSQLite, looks
  //       like test data (name is "IT", different codes).
  
  /// The name of the contact at the company.
  @Attribute(originalName: "ContactName")
  public var contactName  : String?
  /// The title of the contact at the company.
  @Attribute(originalName: "ContactTitle")
  public var contactTitle : String?
  
  /**
   * The address/street the customer is operating from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Address")
  public var address          : String?
  
  /**
   * The city the customer is operating from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "City")
  public var city             : String?

  /**
   * The region/state customer is operating from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Region")
  public var region           : String?

  /**
   * The postal code of the customer's address.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "PostalCode")
  public var postalCode       : String?

  /**
   * The country the customer is operating from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Country")
  public var country          : String?

  /// The phone number of the customer.
  @Attribute(originalName: "Phone")
  public var phone        : String?
  /// The fax number of the customer (doesn't have email just yet).
  @Attribute(originalName: "Fax")
  public var fax          : String?
  
  /// The demographics associated w/ the customer.
  /// This isn't actually filled in the demo database.
  @Relationship(deleteRule: .nullify)
  public var demographics : [ CustomerDemographic ]
  
  /// The ``Order``s the customer has issued.
  @Relationship(deleteRule: .cascade, inverse: \Order.customer)
  public var orders       : [ Order ]
  
  
  /**
   * Create a new customer object.
   *
   * - Parameters:
   *   - code:         A unique 5-character ID for the customer, e.g. `LONEP`.
   *   - companyName:  The name of the company, does NOT have to be unique!
   *   - contactName:  The name of the contact at the company.
   *   - contactTitle: The title of the contact at the company.
   *   - address:      The address/street of the customer.
   *   - city:         The city from where the customer operates.
   *   - region:       The region/state from where the customer operates.
   *   - postalCode:   The postal code of the customers address.
   *   - country:      The country from where the customer operates.
   *   - phone:        The phone number of the customer.
   *   - fax:          The fax number of the customer.
   *   - demographics: The demographics associated w/ the customer.
   *   - orders:       The ``Order``s the customer has issued.
   */
  public init(code: String, companyName: String,
              contactName: String? = nil, contactTitle: String? = nil,
              address:     String? = nil, city:         String? = nil,
              region:      String? = nil, postalCode:   String? = nil,
              country:     String? = nil,
              phone:       String? = nil, fax:          String? = nil,
              demographics: [ CustomerDemographic ] = [],
              orders: [ Order ] = [])
  {
    self.code         = code
    self.companyName  = companyName
    self.contactName  = contactName
    self.contactTitle = contactTitle
    self.address      = address
    self.city         = city
    self.region       = region
    self.postalCode   = postalCode
    self.country      = country
    self.phone        = phone
    self.fax          = fax
    self.demographics = demographics
    self.orders       = orders
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, code, companyName
    case contactName, contactTitle
    case address
    case phone, fax
    case demographics
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode         (id,           forKey: .id)
    try container.encode         (code,         forKey: .code)
    try container.encode         (companyName,  forKey: .companyName)
    
    try container.encodeIfPresent(contactName,  forKey: .contactName)
    try container.encodeIfPresent(contactTitle, forKey: .contactTitle)
    
    try container.encodeIfPresent(structuredAddress, forKey: .address)
    
    try container.encodeIfPresent(phone,        forKey: .phone)
    try container.encodeIfPresent(fax,          forKey: .fax)
    
    if !demographics.isEmpty {
      try container.encode(demographics.map(\.id), forKey: .demographics)
    }
  }
}

extension Customer: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Customer[0x\(oid)]: \(code) '\(companyName)'"
    
    if let contactName, !contactName.isEmpty {
      ms += " contact='\(contactName)'"
      if let contactTitle, !contactTitle.isEmpty { ms += "[\(contactTitle)]" }
    }
    
    // omit postalCode, address, region, fax
    if let v = city,    !v.isEmpty { ms += " \(v)" }
    if let v = country, !v.isEmpty { ms += " \(v)" }
    if let v = phone,   !v.isEmpty { ms += " \(v)" }
    
    #if false // don't trigger a fetch
    if !orders      .isEmpty { ms += " orders=#\(orders.count)"       }
    if !demographics.isEmpty { ms += " orders=#\(demographics.count)" }
    #endif
    return ms
  }
}
