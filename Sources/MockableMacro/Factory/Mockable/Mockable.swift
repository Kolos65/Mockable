//
//  Mockable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

/// Defines a protocol for creating mock implementations.
///
/// Requirements conforming to `Mockable` can generate mock versions of themselves.
protocol Mockable {
    /// Creates a mock declaration.
    ///
    /// - Parameter modifiers: Modifiers to apply to the mock declaration.
    /// - Throws: If the mock cannot be generated.
    /// - Returns: The mock declaration of the requirements.
    func implement(with modifiers: DeclModifierListSyntax) throws -> DeclSyntax
}
