//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData

/**
 * A territory Northwind operates in.
 *
 * Each territory has a unique ``code`` (like "85014"),
 * a ``name`` (e.g. "Phoenix") and it belongs to a ``Region`` (``region``).
 *
 * Territories are grouped into ``Region``s (e.g. "Northern").
 *
 * ``Employee``s are responsible for a set of territories,
 * multiple employees can be responsible for the same territory though.
 *
 * Example territories:
 * - "Austin"
 * - "Cambridge"
 * - "Wilton"
 */
@Model
public final class Territory: Encodable {
  
  /// A numeric code representing the territory, often the zip code.
  @Attribute(.unique, originalName: "TerritoryID")
  public var code      : String
  
  /// The name of the territory (e.g. "Dallas").
  @Attribute(originalName: "TerritoryDescription")
  public var name      : String

  /// The ``Region`` the territory belongs to, e.g. "Southern".
  @Relationship(deleteRule: .nullify, originalName: "RegionID")
  public var region    : Region!
  // This can't be non-optional, raises in init.
  
  /// The ``Employee``s responsible for this territory.
  @Relationship(deleteRule: .nullify, inverse: \Employee.territories)
  public var employees : [ Employee ]
  
  
  /**
   * Create a new Territory.
   *
   * - Parameters:
   *   - code:      A unique numeric code representing the territory.
   *   - name:      The name of the territory.
   *   - region:    The ``Region`` the territory belongs to.
   *   - employees: The ``Employee``s responsible for this territory.
   */
  public init(code: String, name: String, region: Region,
              employees: [ Employee ] = [])
  {
    self.code      = code
    self.name      = name
    self.region    = region
    self.employees = employees
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, code, name
    case region, employees
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id,   forKey: .id)
    try container.encode(code, forKey: .code)
    if !name.isEmpty { try container.encode(name, forKey: .name) }
    
    if let region { try container.encode(region.id, forKey: .region) }
    if !employees.isEmpty {
      try container.encode(employees.map(\.id), forKey: .employees)
    }
  }
}

extension Territory: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Territory[0x\(oid)]: \(code) '\(name)'"
    #if false // don't trigger a fetch
    if let v = region { ms += " region=\(v.name)" }
    if !employees.isEmpty  { ms += " employees=#\(employees.count)" }
    #endif
    return ms
  }
}
