//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import SwiftData

// Note: Could be provided as a computed property on the protocol, but this
//       way the key pathes are only build once.

extension Category: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Category.self)
}
extension Customer: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Customer.self)
}
extension CustomerDemographic: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: CustomerDemographic.self)
}
extension Employee: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Employee.self)
}
extension Order: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Order.self)
}
extension OrderDetail: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: OrderDetail.self)
}
extension Product: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Product.self)
}
extension Region: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Region.self)
}
extension Shipper: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Shipper.self)
}
extension Supplier: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Supplier.self)
}
extension Territory: PredicateCodableKeyPathProviding {
  public static let predicateCodableKeyPaths =
    buildKeyPathMap(for: Territory.self)
}

private let prefix = "de.zeezide.Northwind"

private func buildKeyPathMap<M>(for type: M.Type, typeName: String? = nil)
  -> [ String : PartialKeyPath<M> ]
  where M: PersistentModel
{
  let typeName = typeName ?? _typeName(type, qualified: false)
  var map = [ String : PartialKeyPath<M> ]()
  for propMeta in M.schemaMetadata {
    // ( name, anyKeyPath, _, _ )
    /*
     L: Optional("name") V: timestamp
     L: Optional("keypath") V: \Item.timestamp
     L: Optional("defaultValue") V: nil
     L: Optional("metadata") V: nil
     */
    let mirror  = Mirror(reflecting: propMeta)
    var name    : String?
    var keypath : AnyKeyPath?
    for ( label, value ) in mirror.children {
      if name == nil, label == "name" {
        name = value as? String
      }
      else if keypath == nil, label == "keypath" {
        keypath = value as? AnyKeyPath
      }
      if name != nil && keypath != nil { break }
    }
    guard let name, let keypath else {
      assertionFailure("Could not mirror meta properly: \(mirror)")
      continue
    }
    
    guard let partialKeyPath = keypath as? PartialKeyPath<M> else {
      assertionFailure("Unsupported KeyPath: \(keypath)")
      continue
    }
    map["\(prefix).\(typeName).\(name)"] = partialKeyPath
  }
  return map
}
