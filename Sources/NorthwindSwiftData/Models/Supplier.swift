//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData

/**
 * A supplier that can ship a given ``Product``.
 *
 * Contains the name, the address and contact information for the supplier.
 *
 * Holds all the ``products`` the supplier can ship. Each ``Product`` has a
 * single supplier assigned in Northwind.
 *
 * Supplier conforms to the ``AddressHolder`` protocol, which allows
 * address retrieval as either an ``StructuredAddress`` structure using the
 * ``StructuredAddressProvider/structuredAddress`` property.
 * Or as a `CNPostalAddress` using the
 * ``StructuredAddressProvider/postalAddress`` property.
 *
 * Example suppliers in the database:
 * - "Exotic Liquids", London, UK
 * - "Bigfoot Breweries", Bend, NA
 * - "Heli Süßwaren GmbH & Co. KG", Berlin, Germany
 */
@Model
public final class Supplier: AddressHolder {
  
  /// The name of the supplier company.
  @Attribute(originalName: "CompanyName")
  public var companyName  : String
  
  /// The name of the contact at the supplier.
  @Attribute(originalName: "ContactName")
  public var contactName  : String?

  /// The title of the contact at the supplier.
  @Attribute(originalName: "ContactTitle")
  public var contactTitle : String?
  
  /**
   * The address/street the supplier operates from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Address")
  public var address : String?
  
  /**
   * The city the supplier operates from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "City")
  public var city : String?

  /**
   * The region/state the supplier operates from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Region")
  public var region : String?

  /**
   * The postal code for the place the supplier operates from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "PostalCode")
  public var postalCode : String?

  /**
   * The country the supplier operates from.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Country")
  public var country : String?

  /// The phone number of the supplier.
  @Attribute(originalName: "Phone")
  public var phone : String?
  
  /// The fax number of the supplier.
  @Attribute(originalName: "Fax")
  public var fax   : String?

  /// The World Wide Web homepage of the supplier.
  /// Those have a funny format, e.g. `#CAJUN.HTM#` or
  /// `Mayumi's (on the World Wide Web)#http://www.microsoft.com/accessdev/sampleapps/mayumi.htm#`
  @Attribute(originalName: "HomePage")
  public var homePage     : String?

  /// The ``Product``s the supplier can supply to Northwind.
  @Relationship(deleteRule: .nullify)
  public var products : [ Product ]
  
  
  /**
   * Create a new supplier object.
   *
   * - Parameters:
   *   - companyName:  The name of the supplier company.
   *   - contactName:  The name of the contact at the supplier.
   *   - contactTitle: The title of the contact at the supplier.
   *   - address:      The address/street of the supplier.
   *   - city:         The city from where the supplier operates.
   *   - region:       The region/state from where the supplier operates.
   *   - postalCode:   The postal code of the supplier address.
   *   - country:      The country from where the supplier operates.
   *   - phone:        The phone number of the supplier.
   *   - fax:          The fax number of the supplier.
   *   - homePage:     The World Wide Web homepage of the supplier.
   *   - products:     The ``Product``s the supplier can supply to Northwind.
   */
  public init(companyName: String,
              contactName: String? = nil, contactTitle: String? = nil,
              address:     String? = nil, city:         String? = nil,
              region:      String? = nil, postalCode:   String? = nil,
              country:     String? = nil,
              phone:       String? = nil, fax:          String? = nil,
              homePage:    String? = nil,
              products:    [ Product ] = [])
  {
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
    self.homePage     = homePage
    self.products     = products
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, companyName
    case contactName, contactTitle
    
    case address
    case phone, fax, homePage
    case products
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode         (id,           forKey: .id)
    try container.encode         (companyName,  forKey: .companyName)
    
    try container.encodeIfPresent(contactName,  forKey: .contactName)
    try container.encodeIfPresent(contactTitle, forKey: .contactTitle)
    
    try container.encodeIfPresent(structuredAddress, forKey: .address)
    
    try container.encodeIfPresent(phone,        forKey: .phone)
    try container.encodeIfPresent(fax,          forKey: .fax)
    try container.encodeIfPresent(homePage,     forKey: .homePage)
    
    if !products.isEmpty {
      try container.encode(products.map(\.id),  forKey: .products)
    }
  }
}

extension Supplier: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Supplier[0x\(oid)]: \(companyName)"
    
    if let contactName, !contactName.isEmpty {
      ms += " contact='\(contactName)'"
      if let contactTitle, !contactTitle.isEmpty { ms += "[\(contactTitle)]" }
    }
    
    // omit postalCode, address, region, fax, homePage
    if let v = city,    !v.isEmpty { ms += " \(v)" }
    if let v = country, !v.isEmpty { ms += " \(v)" }
    if let v = phone,   !v.isEmpty { ms += " \(v)" }
    
    #if false // don't trigger a fetch
    if !products.isEmpty  { ms += " products=#\(products.count)" }
    #endif
    return ms
  }
}
