//
//  Factory.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 28..
//

import SwiftSyntax

/// Defines a generic factory protocol for generating syntax of the mock implementation.
///
/// This protocol serves as a blueprint for factory types that transform the protocol requirements
/// into a mock implementation.
protocol Factory {
    /// The type of syntax produced by the factory.
    associatedtype Result: SyntaxProtocol

    /// Generates a syntax using the given requirements.
    ///
    /// - Parameter requirements: Groupped protocol requirements to generate syntax for.
    /// - Throws: Throws an error if the construction fails, which could be due to invalid
    ///   requirements or other issues that prevent the successful generation of the result.
    /// - Returns: An instance of the associated `Result` type, representing the generated
    ///   syntax structure.
    static func build(from requirements: Requirements) throws -> Result
}
