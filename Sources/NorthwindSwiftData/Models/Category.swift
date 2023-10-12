//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftData

public typealias ProductCategory = Category

/**
 * A ``Product`` category, e.g. "Meat/Poultry".
 *
 * Has a ``name``, an optional ``picture`` and ``info``,
 * and the set of associated ``Product``s (``products`` property).
 *
 * **Note**: This name clashes w/ the `ObjectiveC.Category` typealias,
 *           refer to it using the Northwind ``ProductCategory`` alias or
 *           ``NorthwindSchema/Category``.
 */
@Model
public final class Category: Encodable {
  
  /// The name of the product category.
  @Attribute(.unique, originalName: "CategoryName")
  public var name     : String
  
  /// An optional string describing the category.
  @Attribute(originalName: "Description")
  public var info     : String?
  
  /// The JPEG data for a picture associated w/ the category.
  @Attribute(originalName: "Picture")
  public var picture  : Photo?
  
  /// All the products belonging to this category.
  @Relationship(deleteRule: .nullify)
  public var products : [ Product ]
  
  /**
   * Create a new category with the individual fields.
   *
   * - Parameters:
   *   - name:     The name of the product category.
   *   - info:     An optional string describing the category.
   *   - picture:  The JPEG data for a picture associated w/ the category.
   *   - products: All the products belonging to this category.
   */
  public init(name: String, info: String? = nil, picture: Photo? = nil,
              products: [ Product ] = [])
  {
    self.name     = name
    self.info     = info
    self.picture  = picture
    self.products = products
  }
  
  /// Whether the category has any products assigned.
  public var hasProducts : Bool { !products.isEmpty }
  
  /// Whether the photo is available.
  public var hasPhoto : Bool { !(picture?.isEmpty ?? true) }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, name, info, picture, products
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode         (id,      forKey: .id)
    try container.encode         (name,    forKey: .name)
    try container.encodeIfPresent(info,    forKey: .info)
    try container.encodeIfPresent(picture, forKey: .picture)
    if !products.isEmpty {
      try container.encode(products.map(\.id), forKey: .products)
    }
  }
}

extension Category: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Category[0x\(oid)]: '\(name)'"

    if let v = info, !v.isEmpty {
      if v.count < 30 { ms += " \"\(v)\"" }
      else { ms += " \"\(v.prefix(19))…\"" }
    }
    
    if let v = picture, !v.isEmpty { ms += " picture=\(v.count) bytes" }
    
    #if false // don't trigger a fetch
    if !products.isEmpty { ms += " products=#\(products.count)" }
    #endif
    return ms
  }
}
