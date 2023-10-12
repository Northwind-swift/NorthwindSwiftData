//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation

/**
 * Can be implemented by values that can represent an address (or contains an
 * associated address).
 *
 * This is a subprotocol of ``StructuredAddressProvider`` that carries the
 * address information in a set of plain properties (city, country, etc).
 *
 * The information is provided as an ``StructuredAddress`` value using the
 * ``StructuredAddressProvider/structuredAddress`` property.
 *
 * Example:
 * ```swift
 * let customer : Customer
 * let address  = customer.structuredAddress
 * ```
 *
 * If the Apple `Contacts` framework is available, a provider can also
 * provide the address as a `CNPostalAddress` using the
 * ``StructuredAddressProvider/postalAddress`` property.
 */
public protocol AddressHolder: StructuredAddressProvider {

  /// The address/street of the structured address.
  var address    : String? { get }

  /// The city of the structured address.
  var city       : String? { get }

  /// The region/state of the structured address.
  var region     : String? { get }

  /// The postal code of the structured address.
  var postalCode : String? { get }
  
  /// The country of the structured address.
  var country    : String? { get }
}

public extension AddressHolder {
  
  var structuredAddress : StructuredAddress? {
    let address = StructuredAddress(
      address: self.address, city: city, region: region, postalCode: postalCode,
      country: country
    )
    return address.isEmpty ? nil : address
  }
}
