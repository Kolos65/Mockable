//
//  Buildable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

/// An enum representing the different builder structs to generate.
enum BuilderKind: CaseIterable {
    case `return`
    case action
    case verify

    /// The builder struct declaration's name.
    var name: TokenSyntax {
        switch self {
        case .return: NS.ReturnBuilder
        case .action: NS.ActionBuilder
        case .verify: NS.VerifyBuilder
        }
    }

    /// The builder struct declaration's type.
    var type: IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: name)
    }
}

/// A protocol to associate builder functions with individual requirements.
///
/// Used to generate members of builder struct declarations in builder factory.
protocol Buildable {
    /// Returns the specified builder implementation.
    ///
    /// - Parameter kind: The kind of builder function to generate.
    /// - Parameter modifiers: Declaration modifiers to add to the builder.
    /// - Parameter mockType: The enclosing mock service's type.
    /// - Returns: A function or variable declaration that mirrors a protocol requirement
    /// with its syntax. The parameters of the generated declaration are wrapped in the `Parameter`
    /// wrapper, and it returns the corresponding builder object.
    func builder(
        of kind: BuilderKind,
        with modifiers: DeclModifierListSyntax,
        using mockType: IdentifierTypeSyntax
    ) throws -> DeclSyntax
}
