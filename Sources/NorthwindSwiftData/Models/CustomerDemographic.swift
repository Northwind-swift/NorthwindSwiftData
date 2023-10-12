//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData

/**
 * A typed grouping of customers.
 *
 * **Note**: The ported SQLite database doesn't come w/ prefilled demographics.
 *
 * It includes a n:m relationship to ``Customer``.
 */
@Model
public final class CustomerDemographic: Encodable {
  
  /// A unique id for the demographic type.
  @Attribute(.unique, originalName: "CustomerTypeID")
  public var typeID    : String  // pkey in original
  
  /// Text describing the demographics.
  @Attribute(originalName: "CustomerDesc")
  public var info      : String?
  
  /// The ``Customer``s associated w/ this demographic.
  @Relationship(deleteRule: .nullify)
  public var customers : [ Customer ]
  
  /**
   * Create a new demographic.
   *
   * - Parameters:
   *   - typeID:    A unique id for the demographic type.
   *   - info:      Text describing the demographics.
   *   - customers: The associated ``Customer``s.
   */
  public init(typeID: String, info: String? = nil,
              customers: [ Customer ] = [])
  {
    self.typeID    = typeID
    self.info      = info
    self.customers = customers
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, typeID, info
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode         (id,     forKey: .id)
    try container.encode         (typeID, forKey: .typeID)
    try container.encodeIfPresent(info,   forKey: .info)
  }
}

extension CustomerDemographic: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<CustomerDemographics[0x\(oid)]: \(typeID)"
    
    if let v = info, !v.isEmpty {
      if v.count < 30 { ms += " \"\(v)\"" }
      else { ms += " \"\(v.prefix(19))…\"" }
    }

    #if false // don't trigger a fetch
    if !customers.isEmpty { ms += " customers=#\(customers.count)" }
    #endif
    return ms
  }
}
