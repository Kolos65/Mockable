//
//  CaseIdentifiable.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A protocol for enumerations that can be identified by a unique identifier.
///
/// Enumerations conforming to `CaseIdentifiable` must provide a computed property `id`
/// that returns a unique identifier, typically derived from the type name.
public protocol CaseIdentifiable: Equatable, Hashable {
    /// A computed property that returns a unique identifier for the case.
    var id: String { get }

    /// A computed property that returns a human readably name for member enum cases.
    var name: String { get }

    /// A computed property that returns a human readably description of member parameters.
    var parameters: String { get }
}

extension CaseIdentifiable {
    /// A default implementation of the `id` property, deriving the identifier from the case name.
    ///
    /// The default implementation removes any additional information such as parameters
    /// by splitting the type name at the opening parenthesis.
    public var id: String {
        String(String(describing: self).split(separator: "(")[0])
    }

    /// A default implementation of the `name` property, deriving a human readable name for member enum cases.
    public var name: String {
        guard let lastToken = id.split(separator: "_").last else { return id }
        return String(lastToken)
    }

    /// A default implementation of the `parameters` property, deriving a human readable name for member parameters.
    public var parameters: String {
        let description = String(describing: self)
        guard let index = description.firstIndex(of: "(")  else { return "no parameters" }
        return String(description[index...])
    }
}

extension CaseIdentifiable {
    /// Compares two `CaseIdentifiable` instances for equality based on their unique identifiers.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `CaseIdentifiable`.
    ///   - rhs: The right-hand side `CaseIdentifiable`.
    /// - Returns: `true` if the instances have the same identifier; otherwise, `false`.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes a `CaseIdentifiable` instance using its unique identifier.
    ///
    /// - Parameter hasher: The hasher to use for combining the hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
