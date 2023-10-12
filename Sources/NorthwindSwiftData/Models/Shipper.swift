//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData

/**
 * Information about a shipping company.
 *
 * This just has the ``companyName`` and the ``phone`` number of the shipping
 * company,
 * and all ``Order``s the company has shipped or is reponsible for shipping.
 *
 * The default database contains three shipping companies:
 * - "Federal Shipping"
 * - "Speedy Express"
 * - "United Package"
 */
@Model
public final class Shipper: Encodable {
  
  /// The name of the shipping company, e.g. "Planet Express".
  @Attribute(originalName: "CompanyName")
  public var companyName : String
  
  /// The phone number of the shipping company.
  @Attribute(originalName: "Phone")
  public var phone       : String?
  
  /// The ``Order``s the shipping company has shipped.
  public var orders      : [ Order ]
  
  
  /**
   * Create a new shipping company record.
   *
   * - Parameters:
   *   - companyName: The name of the new shipping company.
   *   - phone:       The phone number, if there is one.
   *   - orders:      The associated ``Order`` models.
   */
  public init(companyName: String, phone: String? = nil,
              orders: [ Order ] = [])
  {
    self.companyName = companyName
    self.phone       = phone
    self.orders      = orders
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, companyName, phone
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id,          forKey: .id)
    try container.encode(companyName, forKey: .companyName)
    
    try container.encodeIfPresent(phone, forKey: .phone)
  }
}

extension Shipper: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Shipper[0x\(oid)]: \(companyName)"
    if let v = phone, !v.isEmpty { ms += " phone=\(v)" }
    #if false // don't trigger a fetch
    if !territories.isEmpty  { ms += " territories=#\(territories.count)" }
    #endif
    return ms
  }
}
