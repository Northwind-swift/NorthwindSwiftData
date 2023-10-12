//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData
  
/**
 * A region groups a set of ``Territory`` records.
 *
 * A region has has a ``name`` and the associated ``territories``.
 *
 * The default database has four regions:
 * - "Eastern"  (#19 territories, e.g. "Westboro" or "Boston")
 * - "Northern" (#11 territories, e.g. "Philadelphia" or "Troy")
 * - "Southern" (#8  territories, e.g. "Orlando" or "Austin")
 * - "Westerns" (#15 territories, e.g. "Menlo Park" or "Campbell")  (typo?)
 */
@Model
public final class Region: Encodable {
  
  /// The name of the region (e.g. "Easter", "Northern").
  @Attribute(.unique, originalName: "RegionDescription")
  public var name        : String
  
  /// The territories that belong to the region.
  @Relationship(deleteRule: .nullify)
  public var territories : [ Territory ]
  
  /**
   * Create a new region.
   *
   * - Parameters:
   *   - name:        The name of the regions.
   *   - territories: The associated territories.
   */
  public init(name: String, territories: [ Territory ] = []) {
    self.name        = name
    self.territories = territories
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, name, territories
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode         (id,   forKey: .id)
    try container.encodeIfPresent(name, forKey: .name)
    if !territories.isEmpty {
      try container.encode(territories.map(\.id), forKey: .territories)
    }
  }
}

extension Region: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Region[0x\(oid)]: \(name)"
    #if false // don't trigger a fetch
    if let v = supplier { ms += " supplier=\(v.companyName)" }
    if !territories.isEmpty  { ms += " territories=#\(territories.count)" }
    #endif
    return ms
  }
}
