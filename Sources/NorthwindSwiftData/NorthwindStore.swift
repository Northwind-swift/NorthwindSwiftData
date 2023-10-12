//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import SwiftData

/**
 * A namespace that provides access to the filled SwiftData Northwind database
 * that ships as a resource part of the package.
 *
 * The contained database is fully bootstrapped from the original
 * NorthwindSQLite database and e.g. contains 77 ``Product``s,
 * 93 ``Customer``s, 29 ``Supplier``s and over 16,000 ``Order``s.
 *
 * It can be opened read-only directly from within the resource bundle,
 * or it can be copied to the default (or a custom) SwiftData storage location.
 * The former can be nice for tests, the latter when actually playing with the
 * database in an own app.
 *
 * To get an in-place read-only ModelContainer, directly accessing the
 * embedded database:
 * ```swift
 * let container = try NorthwindStore.readOnlyModelContainer()
 * ```
 *
 * To bootstrap the Northwind database to the default SwiftData location
 * within an app:
 * ```swift
 * let container = try NorthwindStore.modelContainer()
 * ```
 *
 * SwiftUI example:
 * ```swift
 * @main
 * struct NorthwindApp: App {
 *
 *     var body: some Scene {
 *         WindowGroup {
 *             ContentView()
 *         }
 *         .modelContainer(try! NorthwindStore.modelContainer())
 *     }
 * }
 * ```
 *
 * Models that are part of the store:
 * ``Product``,
 * ``Category`` (``ProductCategory``),
 * ``Order``,
 * ``OrderDetail``,
 * ``Employee``,
 * ``Customer``,
 * ``CustomerDemographic``,
 * ``Supplier``,
 * ``Shipper``,
 * ``Region`` and
 * ``Territory``.
 */
public enum NorthwindStore {
  
  /// The URL at which the prefilled SwiftData Northwind store is stored.
  public static var url =
    Bundle.module.url(forResource: "Northwind", withExtension: "store")!
  
  /**
   * The current SwiftData `Schema` for the NorthwindStore.
   */
  public static var schema = Schema(versionedSchema: NorthwindSchema.self)
  
  /**
   * Returns a SwiftData `ModelContainer` for the Northwind database that
   * exists within the passed in configuration URL, or the default location.
   * If the database doesn't exist in the target directory yet, this function
   * can copy the embedded Northwind store to that location.
   *
   * SwiftUI example:
   * ```swift
   * @main
   * struct NorthwindApp: App {
   *
   *     var body: some Scene {
   *         WindowGroup {
   *             ContentView()
   *         }
   *         .modelContainer(try! NorthwindStore.modelContainer())
   *     }
   * }
   * ```
   *
   * - Parameters:
   *   - bootstrapIfMissing: Create the database, if it is missing. Defaults to
   *                         `true`.
   *   - configurations:     Optional container configurations. E.g. the URL
   *                         specified in the first will be used if it exists.
   * - Returns: A `ModelContainer`.
   */
  public static func modelContainer(bootstrapIfMissing: Bool = true,
                                    _ configurations: ModelConfiguration...)
                       throws -> ModelContainer
  {
    var configurations = configurations
    if configurations.isEmpty, let url = Self.defaultModelStoreURL {
      configurations.append(
        ModelConfiguration(
          "Northwind",
          schema: schema,
          url: url,
          allowsSave: true
        )
      )
    }
    
    if bootstrapIfMissing {
      if let url = configurations.first?.url {
        try bootstrap(to: url, onlyIfMissing: true)
      }
      else {
        try bootstrap(onlyIfMissing: true)
      }
    }
    
    return try ModelContainer(
      for: schema,
      configurations: configurations
    )
  }
  
  /**
   * Returns a readOnly SwiftData `ModelContainer` for the embedded Northwind
   * database.
   *
   * This can be useful to testing.
   *
   * - Returns: A `ModelContainer`.
   */
  public static func readOnlyModelContainer() throws -> ModelContainer {
    try modelContainer(
      bootstrapIfMissing: false,
      
      ModelConfiguration("NorthwindDataReadOnly",
                         schema: schema, url: url, allowsSave: false,
                         cloudKitDatabase: .none)
    )
  }
  
  /**
   * Copies the prefilled Northwind store into to the applications
   * support directory, or other locations if specified.
   *
   * - Parameters:
   *   - url:           If specified, the destination URL to which the database
   *                    will be copied (defaults to `nil`, which will use the
   *                    default SwiftData container location).
   *   - onlyIfMissing: If set to `true` (default), the database is only copied
   *                    if the destination URL doesn't exist yet.
   * - Returns: The `URL` the database was copied to (or where it already
   *            existed)
   */
  @discardableResult
  public static func bootstrap(to url: URL? = nil, onlyIfMissing: Bool = true)
                       throws -> URL
  {
    // Future: Make this atomic.
    // (i.e. move files aside, copy new, restore if failed)
    
    guard let destinationURL = url ?? defaultModelStoreURL else {
      throw BootstrapError.couldNotDetermineDestinationURL
    }
    
    if onlyIfMissing && fileManager.fileExists(atPath: destinationURL.path) {
      return destinationURL // already exists
    }
    
    let folderURL = destinationURL.deletingLastPathComponent()
    let filename  = destinationURL.lastPathComponent
    let walURL    = folderURL.appending(component: filename + "-wal")
    let shmURL    = folderURL.appending(component: filename + "-shm")
    
    if fileManager.fileExists(atPath: destinationURL.path) {
      try fileManager.removeItem(at: destinationURL)
    }
    if fileManager.fileExists(atPath: walURL.path) {
      try fileManager.removeItem(at: walURL)
    }
    if fileManager.fileExists(atPath: shmURL.path) {
      try fileManager.removeItem(at: shmURL)
    }
    
    if !fileManager.fileExists(atPath: folderURL.path) {
      try fileManager
        .createDirectory(at: folderURL, withIntermediateDirectories: true)
    }
    
    try fileManager.copyItem(at: NorthwindStore.url, to: destinationURL)
    return destinationURL
  }
    
  public enum BootstrapError: Swift.Error {
    case couldNotDetermineDestinationURL
  }
  
  private static let fileManager = FileManager.default
  
  private static var defaultModelStoreURL: URL? {
    fileManager
      .urls(for: .applicationSupportDirectory, in: .allDomainsMask)
      .first?
      .appendingPathComponent("default.store")
  }
  
}
