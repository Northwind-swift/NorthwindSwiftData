//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import SwiftData

/**
 * An object representing an Employee of the Northwind GmbH.
 *
 * It has the name, title, address data, phone number, an optional photo
 * and notes.
 * Also tracks the ``Order``s and ``Territory``s the employee is responsible
 * for.
 *
 * Employee conforms to the ``AddressHolder`` protocol, which allows
 * address retrieval as either an ``StructuredAddress`` structure using the
 * ``StructuredAddressProvider/structuredAddress`` property.
 * Or as a `CNPostalAddress` using the
 * ``StructuredAddressProvider/postalAddress`` property.
 *
 * The manager of the employee is herself an employee and the relationship
 * can be managed using the ``Employee/reportsTo`` and
 * ``Employee/managedEmployees``properties.
 *
 * The sample database contains those imaginary employees:
 * - "Nancy Davolio"
 * - "Andrew Fuller"
 * - "Janet Leverling"
 * - "Margaret Peacock"
 * - "Steven Buchanan"
 * - "Michael Suyama"
 * - "Robert King"
 * - "Laura Callahan"
 * - "Anne Dodsworth"
 */
@Model
public final class Employee: Encodable, AddressHolder {
  
  /// The last name (family name) of the employee.
  @Attribute(originalName: "LastName")
  public var lastName         : String
  /// The first name (given name) of the employee.
  @Attribute(originalName: "FirstName")
  public var firstName        : String

  /// The job title of the employee at the company. E.g. "ZEO".
  @Attribute(originalName: "Title")
  public var title            : String?
  
  /// The employee's title of courtesy, e.g. "Madam".
  @Attribute(originalName: "TitleOfCourtesy")
  public var titleOfCourtesy  : String?
  
  /**
   * The birthdate of the employee as a String in the YYYY-MM-DD format.
   * This can also be retrieved using the ``Employee/birthDate`` property
   * as a Foundation `Date` (in the current timezone, at 12:00:00).
   */
  @Attribute(originalName: "BirthDate")
  public var birthDateString  : YMDDate?
  /**
   * The date when the employee was hired as a String in the YYYY-MM-DD
   * format.
   * This can also be retrieved using the ``Employee/hireDate`` property
   * as a Foundation `Date` (in the current timezone, at 12:00:00).
   */
  @Attribute(originalName: "HireDate")
  public var hireDateString   : YMDDate?
  
  /**
   * The address/street the employee is living at.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Address")
  public var address          : String?
  
  /**
   * The city the employee is living in.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "City")
  public var city             : String?

  /**
   * The region/state the employee is living in.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Region")
  public var region           : String?

  /**
   * The postal code for the place the employee is living at.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "PostalCode")
  public var postalCode       : String?

  /**
   * The country the employee is living in.
   *
   * The address can also be retrieved as a `CNPostalAddress` using the
   * ``StructuredAddressProvider/postalAddress`` property,
   * or as a structure ``StructuredAddress`` value using the
   * ``StructuredAddressProvider/structuredAddress`` property.
   */
  @Attribute(originalName: "Country")
  public var country          : String?

  /// The employees phone number at home.
  @Attribute(originalName: "HomePhone")
  public var homePhone        : String?
  
  // @Attribute(originalName: "Extension") => break Swift Data
  /// The employees phone extension within Northwind GmbH.
  public var phoneExtension   : String?

  /// The JPEG photo of the employee.
  @Attribute(originalName: "Photo")
  public var photo            : Photo?
  /// A path to a JPEG photo of the employee.
  @Attribute(originalName: "PhotoPath")
  public var photoPath        : String?
  
  /// Notes attached to the employee record, e.g. whether he was part in
  /// forming a union and such. Careful, not encrypted!
  public var notes            : String?
  
  /// The manager an ``Employee`` reports to.
  @Relationship(deleteRule: .nullify, originalName: "ReportsTo")
  public var reportsTo        : Employee?
  
  /// The ``Employee``s managed by this manager.
  @Relationship(deleteRule: .nullify, inverse: \Employee.reportsTo)
  public var managedEmployees : [ Employee ]
  
  /// The ``Territory``'s the employee is responsible for.
  @Relationship(deleteRule: .nullify)
  public var territories      : [ Territory ]
  
  /// The ``Order``s the employee is responsible for.
  @Relationship(deleteRule: .deny, inverse: \Order.employee)
  public var orders           : [ Order ]
  
  
  /**
   * Create a new employee object.
   *
   * - Parameters:
   *   - lastName:         The last name (family name) of the employee.
   *   - firstName:        The first name (given name) of the employee.
   *   - title:            The job title of the employee at the company.
   *   - titleOfCourtesy:  The employee's title of courtesy, e.g. "Madam".
   *   - birthDateString:  The birthdate of the employee as a String in the
   *                       YYYY-MM-DD format.
   *   - hireDateString:   The date when the employee was hired as a String in
   *                       the YYYY-MM-DD format.
   *   - address:          The address/street of the employee.
   *   - city:             The city from where the employee lives.
   *   - region:           The region/state from where the employee lives.
   *   - postalCode:       The postal code of the employee lives.
   *   - country:          The country from where the employee lives.
   *   - homePhone:        The employees phone number at home.
   *   - phoneExtension:   The employees phone extension within Northwind.
   *   - photo:            The JPEG photo of the employee.
   *   - photoPath:        A path to a JPEG photo of the employee.
   *   - notes:            Notes attached to the employee record.
   *   - reportsTo:        The manager an ``Employee`` reports to.
   *   - managedEmployees: The ``Employee``s managed by this manager.
   *   - territories:      The territories the employee is responsible for.
   *   - orders:           The ``Order``s the employee is responsible for.
   */
  public init(lastName:  String, firstName: String,
              title:     String? = nil, titleOfCourtesy: String? = nil,
              birthDateString: String? = nil, hireDateString: String? = nil,
              birthDate: Date?   = nil, hireDate:   Date?   = nil,
              address:   String? = nil, city:       String? = nil,
              region:    String? = nil, postalCode: String? = nil,
              country:   String? = nil, homePhone:  String? = nil,
              phoneExtension: String? = nil,
              photo:     Photo?  = nil, photoPath:  String? = nil,
              notes:     String? = nil,
              reportsTo: Employee? = nil, managedEmployees: [ Employee ] = [],
              territories: [ Territory ] = [], orders: [ Order ] = [])
  {
    self.lastName         = lastName
    self.firstName        = firstName
    self.title            = title
    self.titleOfCourtesy  = titleOfCourtesy
    self.address          = address
    self.city             = city
    self.region           = region
    self.postalCode       = postalCode
    self.country          = country
    self.homePhone        = homePhone
    self.phoneExtension   = phoneExtension
    self.photo            = photo
    self.photoPath        = photoPath
    self.notes            = notes
    self.reportsTo        = reportsTo
    self.managedEmployees = managedEmployees
    self.territories      = territories
    self.orders           = orders
    
    self.birthDateString = birthDateString ?? birthDate.flatMap {
      dateOnlyFormatter.string(from: $0)
    }
    self.hireDateString = hireDateString ?? hireDate.flatMap {
      dateOnlyFormatter.string(from: $0)
    }
  }
  
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case id, lastName, firstName
    case title, titleOfCourtesy, birthDate, hireDate
    case address
    
    // TODO: Maybe encode as a phone struct
    case homePhone, phoneExtension
    
    case photo, photoPath
    case notes
    case reportsTo
    case territories
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode         (id,                forKey: .id)
    try container.encode         (lastName,          forKey: .lastName)
    try container.encode         (firstName,         forKey: .firstName)
    
    try container.encodeIfPresent(title,             forKey: .title)
    try container.encodeIfPresent(titleOfCourtesy,   forKey: .titleOfCourtesy)
    
    try container.encodeIfPresent(structuredAddress, forKey: .address)
    
    try container.encodeIfPresent(homePhone,         forKey: .homePhone)
    try container.encodeIfPresent(phoneExtension,    forKey: .phoneExtension)
    
    try container.encodeIfPresent(photo,             forKey: .photo)
    try container.encodeIfPresent(photoPath,         forKey: .photoPath)
    
    try container.encodeIfPresent(notes,             forKey: .notes)
    
    try container.encodeIfPresent(birthDateString,   forKey: .birthDate)
    try container.encodeIfPresent(hireDateString,    forKey: .hireDate)
    
    try container.encodeIfPresent(reportsTo?.id,     forKey: .reportsTo)
    
    if !territories.isEmpty {
      try container.encode(territories.map(\.id),    forKey: .territories)
    }
  }
}

extension Employee: CustomStringConvertible {
  
  public var description: String {
    let oid = String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)
    var ms = "<Employee[0x\(oid)]: '\(firstName) \(lastName)'"
    
    // Omit: title, titleOfCourtesy, birthDateString, hireDateString

    if let address = structuredAddress {
      // Omit various
      if let v = address.city,    !v.isEmpty { ms += " \(v)" }
      if let v = address.country, !v.isEmpty { ms += " \(v)" }
    }
    if let v = phoneExtension, !v.isEmpty { ms += " ☎︎\(v)" }

    if let v = photo, !v.isEmpty { ms += " photo=\(v.count) bytes" }
    else if let v = photoPath, !v.isEmpty { ms += " path-to-photo=\(v)"}

    if let v = notes, !v.isEmpty {
      if v.count < 30 { ms += " \"\(v)\"" }
      else { ms += " \"\(v.prefix(19))…\"" }
    }

    #if false // don't trigger a fetch
    if !orders     .isEmpty { ms += " orders=#\(orders.count)"           }
    if !territories.isEmpty { ms += " territories=#\(territories.count)" }
    if let v = reportsTo { ms += " manager=\(v)" }
    if !managedEmployees.isEmpty {
      ms += " managedEmployees=#\(managedEmployees.count)"
    }
    #endif
    return ms
  }}

public extension Employee {
  
  /**
   * Whether the employee is a manager, i.e. whether other people report to
   * her.
   */
  var isManager : Bool {
    !managedEmployees.isEmpty
  }
  
  /**
   * Retrieve the name components as a Foundation `PersonNameComponents`
   * object (which can be formatted using the `PersonNameComponentsFormatter`).
   */
  var nameComponents : PersonNameComponents {
    PersonNameComponents(givenName: firstName, familyName: lastName)
  }
  
  /**
   * Returns the birthdate of the employee as a Foundation `Date` object.
   * The date is stored as a string in the YYYY-MM-DD format (accessible
   * using the ``Employee/birthDateString`` property.
   *
   * This is using the current timezone in the process, at 12:00:00.
   */
  var birthDate : Date? {
    set {
      birthDateString = newValue.flatMap { dateOnlyFormatter.string(from: $0) }
    }
    get {
      guard let string = birthDateString, !string.isEmpty else { return nil }
      let date = dateOnlyFormatter.date(from: string)
      assert(date != nil, "Could not parse date string \(string)!")
      return date
    }
  }
  /**
   * Returns the date when the employee was hired as a Foundation `Date` object.
   * The date is stored as a string in the YYYY-MM-DD format (accessible
   * using the ``Employee/hireDateString`` property.
   *
   * This is using the current timezone in the process, at 12:00:00.
   */
  var hireDate  : Date? {
    set {
      hireDateString = newValue.flatMap { dateOnlyFormatter.string(from: $0) }
    }
    get {
      guard let string = hireDateString, !string.isEmpty else { return nil }
      let date = dateOnlyFormatter.date(from: string)
      assert(date != nil, "Could not parse date string \(string)!")
      return date
    }
  }
}


// MARK: - Date Helpers

private let defaultDate : Date = {
  let dc = DateComponents(
    calendar: Calendar.current,
    timeZone: Calendar.current.timeZone,
    year: 1973, month: 1, day: 31,
    hour: 12, minute: 0, second: 0 // Meh
  )
  return Calendar.current.date(from: dc)!
}()

private let dateOnlyFormatter : DateFormatter = {
  let fmt = DateFormatter()
  fmt.dateFormat  = "yyyy-MM-dd"
  fmt.defaultDate = defaultDate
  return fmt
}()
