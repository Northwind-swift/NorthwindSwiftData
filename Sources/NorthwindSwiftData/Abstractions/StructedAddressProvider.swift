//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation

/**
 * Can be implemented by values that can represent an address (or contains an
 * associated address).
 *
 * The information is provided as an ``StructuredAddress`` value using the
 * ``structuredAddress`` property.
 *
 * Example:
 * ```swift
 * let customer : Customer
 * let address  = customer.structuredAddress
 * ```
 *
 * If the Apple `Contacts` framework is available, a provider can also
 * provide the address as a `CNPostalAddress` using the``postalAddress``
 * property.
 *
 * The is the ``AddressHolder`` extended subprotocol, which can produce
 * structured address values based on individual fields (address, city, etc).
 */
public protocol StructuredAddressProvider {
  
  /// The address represented by or associated with the provider.
  var structuredAddress : StructuredAddress? { get }
}


#if canImport(Contacts)
import Contacts

public extension StructuredAddressProvider {
  
  /// The address represented by or associated with the provider as a
  /// `CNPostalAddress` (via the Apple `Contacts` framework).
  var postalAddress : CNPostalAddress {
    structuredAddress?.postalAddress ?? CNPostalAddress()
  }
}

#endif // canImport(Contacts)
