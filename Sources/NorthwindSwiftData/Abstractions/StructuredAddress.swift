//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation

/**
 * A value representing a Northwind address in a more structured way.
 *
 * If Apple's `Contacts` framework is available, the address can be converted
 * to a `CNPostalAddress` using the ``postalAddress`` property.
 *
 * Note: This is intended to match the Northwind schema. It is not a good format
 *       for newer databases.
 */
public struct StructuredAddress: Codable, Hashable, AddressHolder {

  /// The name associated w/ the address.
  public var name       : String?

  /// The address/street of the structured address.
  public var address    : String?

  /// The city of the structured address.
  public var city       : String?

  /// The region/state of the structured address.
  public var region     : String?

  /// The postal code of the structured address.
  public var postalCode : String?
  
  /// The country of the structured address.
  public var country    : String?

  /**
   * Create a new structure address from the individual property values.
   *
   * All values default to `nil`.
   *
   * - Parameters:
   *   - name:       The name associated w/ the address.
   *   - address:    The address/street of the structured address.
   *   - city:       The city of the structured address.
   *   - region:     The region/state of the structured address.
   *   - postalCode: The postal code of the structured address.
   *   - country:    The country of the structured address.
   */
  public init(name: String? = nil, address: String? = nil, city: String? = nil,
              region: String? = nil, postalCode: String? = nil,
              country: String? = nil)
  {
    func clean(_ string: String?) -> String? {
      guard let string, !string.isEmpty else { return nil }
      return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    self.name       = clean(name)
    self.address    = clean(address)
    self.city       = clean(city)
    self.region     = clean(region)
    self.postalCode = clean(postalCode)
    self.country    = clean(country)
  }
}

public extension StructuredAddress {
  
  /// Returns true if none of the fields is set.
  var isEmpty : Bool {
    if let v = name,       !v.isEmpty { return false }
    if let v = address,    !v.isEmpty { return false }
    if let v = city,       !v.isEmpty { return false }
    if let v = region,     !v.isEmpty { return false }
    if let v = postalCode, !v.isEmpty { return false }
    if let v = country,    !v.isEmpty { return false }
    return true
  }
}


extension StructuredAddress: CustomStringConvertible {
  
  public var description: String {
    var ms = "<Address:"
    if let v = name,       !v.isEmpty { ms += " \(v)" }
    if let v = address,    !v.isEmpty { ms += " \(v)" }
    if let v = city,       !v.isEmpty { ms += " \(v)" }
    if let v = region,     !v.isEmpty { ms += " \(v)" }
    if let v = postalCode, !v.isEmpty { ms += " \(v)" }
    if let v = country,    !v.isEmpty { ms += " \(v)" }
    return ms
  }
}


#if canImport(Contacts)
import Contacts

public extension StructuredAddress {
  
  /// The address as a `CNPostalAddress` (via the Apple `Contacts` framework).
  /// Note: This doesn't cover the name associated w/ the address.
  var postalAddress : CNPostalAddress {
    let address = CNMutablePostalAddress()
    if let v = self.address    { address.street     = v }
    if let v = self.city       { address.city       = v }
    if let v = self.postalCode { address.postalCode = v }
    if let v = self.region     { address.state      = v } // TBD
    if let v = self.country    { address.country    = v }
    let immutable = address.copy() as? CNPostalAddress
    assert(immutable != nil, "Could not produce immutable version of address?")
    return immutable ?? address
  }
}

#endif // canImport(Contacts)
